/*
 * Author:      Foo Kim Chean
 * Description: Student lesson viewer page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class Lesson : Page
{
    // Store current IDs for navigation
    private int courseId  = 0;
    private int lessonId  = 0;
    private int userId    = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Protect page — must be logged in
        if (Session["UserId"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        userId = int.Parse(Session["UserId"].ToString());

        // Get courseId and lessonId from URL query string
        int.TryParse(Request.QueryString["courseId"], out courseId);
        int.TryParse(Request.QueryString["lessonId"], out lessonId);

        if (courseId <= 0)
        {
            Response.Redirect("CourseList.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadLessonPage();
        }
    }

    private void LoadLessonPage()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            bool isAdmin = Session["UserType"] != null && Session["UserType"].ToString() == "admin";

            if (!isAdmin)
            {
                SqlCommand publishCheck = new SqlCommand(
                    "SELECT COUNT(*) FROM Courses WHERE course_id=@cid AND published=1", conn);
                publishCheck.Parameters.AddWithValue("@cid", courseId);

                if ((int)publishCheck.ExecuteScalar() == 0)
                {
                    Response.Redirect("CourseList.aspx");
                    return;
                }
            }

            // Check if student is enrolled in this course
            SqlCommand enrollCheck = new SqlCommand(
                "SELECT COUNT(*) FROM Enrollment WHERE user_id=@uid AND course_id=@cid", conn);
            enrollCheck.Parameters.AddWithValue("@uid", userId);
            enrollCheck.Parameters.AddWithValue("@cid", courseId);

            bool isEnrolled = (int)enrollCheck.ExecuteScalar() > 0;

            // Admins can view any lesson without enrollment
            if (!isEnrolled && !isAdmin)
            {
                pnlNotEnrolled.Visible = true;
                pnlLesson.Visible = false;
                return;
            }

            // If no specific lesson selected, load first lesson of the course
            if (lessonId <= 0)
            {
                SqlCommand firstLesson = new SqlCommand(
                    "SELECT TOP 1 lesson_id FROM Lessons WHERE course_id = @cid ORDER BY lesson_id", conn);
                firstLesson.Parameters.AddWithValue("@cid", courseId);
                object result = firstLesson.ExecuteScalar();
                if (result == null)
                {
                    pnlLesson.Visible = false;
                    return;
                }
                lessonId = (int)result;
            }

            // Load lesson data
            SqlCommand lessonCmd = new SqlCommand(
                @"SELECT l.lesson_id, l.lesson_title, l.lesson_content, l.video_url,
                         c.course_name, c.course_id
                  FROM Lessons l
                  INNER JOIN Courses c ON l.course_id = c.course_id
                  WHERE l.lesson_id = @lid AND l.course_id = @cid", conn);
            lessonCmd.Parameters.AddWithValue("@lid", lessonId);
            lessonCmd.Parameters.AddWithValue("@cid", courseId);

            SqlDataReader reader = lessonCmd.ExecuteReader();

            if (!reader.Read())
            {
                reader.Close();
                pnlLesson.Visible = false;
                return;
            }

            string lessonTitle   = reader["lesson_title"].ToString();
            string lessonContent = reader["lesson_content"].ToString();
            string videoUrl      = reader["video_url"] == DBNull.Value ? "" : reader["video_url"].ToString();
            string courseName    = reader["course_name"].ToString();

            reader.Close();

            // Persist resolved lessonId so postback handlers get the right value
            hdnCurrentLessonId.Value = lessonId.ToString();

            // Set lesson UI fields
            litTitle.Text       = Server.HtmlEncode(lessonTitle);
            litLessonTitle.Text = Server.HtmlEncode(lessonTitle);
            litCourseName.Text  = Server.HtmlEncode(courseName);
            litLessonBread.Text = Server.HtmlEncode(lessonTitle);
            litCourseMeta.Text  = Server.HtmlEncode(courseName);
            litDuration.Text    = "~15 min";
            litContent.Text     = Server.HtmlEncode(lessonContent).Replace("\n", "<br/>");
            aCourseBread.HRef   = "Lesson.aspx?courseId=" + courseId;

            // Embed video
            if (!string.IsNullOrEmpty(videoUrl))
            {
                // Normalise YouTube URLs — converts watch/short links to embed format
                string embedUrl = ConvertToYouTubeEmbed(videoUrl);

                if (embedUrl != null)
                {
                    // YouTube iframe embed
                    var iframe = new HtmlGenericControl("iframe");
                    iframe.Attributes["src"] = embedUrl;
                    iframe.Attributes["allow"] = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture";
                    iframe.Attributes["allowfullscreen"] = "true";
                    iframe.Attributes["frameborder"] = "0";
                    phVideo.Controls.Add(iframe);
                }
                else
                {
                    // Direct video file (MP4 or similar)
                    var video = new HtmlGenericControl("video");
                    video.Attributes["controls"] = "controls";
                    video.Attributes["style"] = "width:100%;height:100%;";
                    var source = new HtmlGenericControl("source");
                    source.Attributes["src"] = videoUrl;
                    source.Attributes["type"] = "video/mp4";
                    video.Controls.Add(source);
                    phVideo.Controls.Add(video);
                }
            }
            else
            {
                // Placeholder if no video
                var placeholder = new HtmlGenericControl("div");
                placeholder.Attributes["class"] = "video-placeholder";
                placeholder.InnerHtml = "<div class='play-icon'>&#9654;</div><span>Video Content Area</span>";
                phVideo.Controls.Add(placeholder);
            }

            // Load sidebar lesson list + progress
            LoadLessonList(conn, courseId, lessonId, userId);

            // Check for quiz in this course
            SqlCommand quizCheck = new SqlCommand(
                "SELECT TOP 1 quiz_id FROM Quizzes WHERE course_id = @cid ORDER BY quiz_id", conn);
            quizCheck.Parameters.AddWithValue("@cid", courseId);
            object quizId = quizCheck.ExecuteScalar();

            if (quizId != null)
            {
                hlTakeQuiz.NavigateUrl = "Quiz.aspx?quizId=" + quizId.ToString();
                hlTakeQuiz.Visible = true;
            }

            // Set prev/next button states
            SetNavigationButtons(conn, courseId, lessonId);
        }
    }

    // Load sidebar lesson list with completion status
    private void LoadLessonList(SqlConnection conn, int cid, int currentLid, int uid)
    {
        string sql = @"
            SELECT
                l.lesson_id,
                l.lesson_title,
                l.course_id,
                ROW_NUMBER() OVER (ORDER BY l.lesson_id) AS lesson_num,
                CASE WHEN lp.is_completed = 1 THEN 1 ELSE 0 END AS is_completed_val,
                CASE WHEN l.lesson_id = @currentLid THEN 1 ELSE 0 END AS is_current_val
            FROM Lessons l
            LEFT JOIN Lesson_Progress lp ON l.lesson_id = lp.lesson_id AND lp.user_id = @uid
            WHERE l.course_id = @cid
            ORDER BY l.lesson_id";

        SqlCommand cmd = new SqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@cid",        cid);
        cmd.Parameters.AddWithValue("@uid",        uid);
        cmd.Parameters.AddWithValue("@currentLid", currentLid);

        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        da.Fill(dt);

        // Add computed bool columns for repeater binding
        dt.Columns.Add("is_completed", typeof(bool));
        dt.Columns.Add("is_current",   typeof(bool));

        int totalLessons = dt.Rows.Count;
        int completedCount = 0;

        foreach (DataRow row in dt.Rows)
        {
            bool done    = Convert.ToInt32(row["is_completed_val"]) == 1;
            bool current = Convert.ToInt32(row["is_current_val"])   == 1;
            row["is_completed"] = done;
            row["is_current"]   = current;
            if (done) completedCount++;
        }

        rptLessonList.DataSource = dt;
        rptLessonList.DataBind();

        // Update progress display
        int pct = totalLessons > 0 ? (completedCount * 100 / totalLessons) : 0;
        lblProgressPct.Text     = pct.ToString();
        litCompletedCount.Text  = completedCount.ToString();
        litTotalLessons.Text    = totalLessons.ToString();
        litProgress.Text        = pct + "%";

        // Set progress bar width
        progressFill.Style["width"]       = pct + "%";
        progressFill.Attributes["data-width"] = pct + "%";
    }

    // Show/hide prev and next buttons based on lesson position
    private void SetNavigationButtons(SqlConnection conn, int cid, int currentLid)
    {
        // Check if there is a previous lesson
        SqlCommand prevCmd = new SqlCommand(
            "SELECT TOP 1 lesson_id FROM Lessons WHERE course_id=@cid AND lesson_id < @lid ORDER BY lesson_id DESC", conn);
        prevCmd.Parameters.AddWithValue("@cid", cid);
        prevCmd.Parameters.AddWithValue("@lid", currentLid);
        bool hasPreviousLesson = prevCmd.ExecuteScalar() != null;
        btnPrevLesson.Visible = hasPreviousLesson;

        // Check if there is a next lesson
        SqlCommand nextCmd = new SqlCommand(
            "SELECT TOP 1 lesson_id FROM Lessons WHERE course_id=@cid AND lesson_id > @lid ORDER BY lesson_id ASC", conn);
        nextCmd.Parameters.AddWithValue("@cid", cid);
        nextCmd.Parameters.AddWithValue("@lid", currentLid);
        bool hasNextLesson = nextCmd.ExecuteScalar() != null;
        btnNextLesson.Visible = hasNextLesson;
    }

    // Mark current lesson as completed
    protected void btnMarkComplete_Click(object sender, EventArgs e)
    {
        int.TryParse(Request.QueryString["courseId"], out courseId);
        // Use the resolved lessonId from the hidden field — handles first lesson (no lessonId in URL)
        int.TryParse(hdnCurrentLessonId.Value, out lessonId);
        if (lessonId <= 0)
            int.TryParse(Request.QueryString["lessonId"], out lessonId);

        if (lessonId <= 0) return;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Check if progress record already exists
            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Lesson_Progress WHERE user_id=@uid AND lesson_id=@lid", conn);
            checkCmd.Parameters.AddWithValue("@uid", userId);
            checkCmd.Parameters.AddWithValue("@lid", lessonId);

            if ((int)checkCmd.ExecuteScalar() > 0)
            {
                // Update existing record
                SqlCommand updateCmd = new SqlCommand(
                    "UPDATE Lesson_Progress SET is_completed=1 WHERE user_id=@uid AND lesson_id=@lid", conn);
                updateCmd.Parameters.AddWithValue("@uid", userId);
                updateCmd.Parameters.AddWithValue("@lid", lessonId);
                updateCmd.ExecuteNonQuery();
            }
            else
            {
                // Insert new progress record
                SqlCommand insertCmd = new SqlCommand(
                    "INSERT INTO Lesson_Progress (user_id, lesson_id, is_completed) VALUES (@uid, @lid, 1)", conn);
                insertCmd.Parameters.AddWithValue("@uid", userId);
                insertCmd.Parameters.AddWithValue("@lid", lessonId);
                insertCmd.ExecuteNonQuery();
            }
        }

        lblCompleteMsg.Text    = "Lesson marked as complete! Great work!";
        lblCompleteMsg.Visible = true;
        btnMarkComplete.Text   = "Completed";
        btnMarkComplete.Enabled = false;

        LoadLessonPage(); // Refresh progress
    }

    // Navigate to previous lesson
    protected void btnPrevLesson_Click(object sender, EventArgs e)
    {
        int.TryParse(Request.QueryString["courseId"], out courseId);
        // Use the hidden field (set in LoadLessonPage) — never 0 even when URL omits lessonId
        int.TryParse(hdnCurrentLessonId.Value, out lessonId);

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 lesson_id FROM Lessons WHERE course_id=@cid AND lesson_id < @lid ORDER BY lesson_id DESC", conn);
            cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.Parameters.AddWithValue("@lid", lessonId);
            object prevId = cmd.ExecuteScalar();

            if (prevId != null)
                Response.Redirect("Lesson.aspx?courseId=" + courseId + "&lessonId=" + prevId);
        }
    }

    // Navigate to next lesson
    protected void btnNextLesson_Click(object sender, EventArgs e)
    {
        int.TryParse(Request.QueryString["courseId"], out courseId);
        // Use the hidden field (set in LoadLessonPage) — never 0 even when URL omits lessonId
        int.TryParse(hdnCurrentLessonId.Value, out lessonId);

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 lesson_id FROM Lessons WHERE course_id=@cid AND lesson_id > @lid ORDER BY lesson_id ASC", conn);
            cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.Parameters.AddWithValue("@lid", lessonId);
            object nextId = cmd.ExecuteScalar();

            if (nextId != null)
                Response.Redirect("Lesson.aspx?courseId=" + courseId + "&lessonId=" + nextId);
        }
    }

    // Converts any YouTube URL format to a YouTube embed URL.
    // Handles: embed URLs (pass-through), watch URLs (?v=), and short youtu.be links.
    // Returns null if the URL is not a YouTube URL (treat as a direct video file).
    private string ConvertToYouTubeEmbed(string url)
    {
        if (url.Contains("youtube.com/embed"))
            return url; // already in embed format — use as-is

        if (url.Contains("youtube.com/watch"))
        {
            // e.g. https://www.youtube.com/watch?v=dQw4w9WgXcQ
            try
            {
                var uri  = new Uri(url);
                var qs   = System.Web.HttpUtility.ParseQueryString(uri.Query);
                string v = qs["v"];
                if (!string.IsNullOrEmpty(v))
                    return "https://www.youtube.com/embed/" + v;
            }
            catch { }
        }

        if (url.Contains("youtu.be/"))
        {
            // e.g. https://youtu.be/dQw4w9WgXcQ
            try
            {
                var uri  = new Uri(url);
                string v = uri.AbsolutePath.TrimStart('/').Split('?')[0];
                if (!string.IsNullOrEmpty(v))
                    return "https://www.youtube.com/embed/" + v;
            }
            catch { }
        }

        return null; // not a YouTube URL — render as HTML5 <video>
    }
}
