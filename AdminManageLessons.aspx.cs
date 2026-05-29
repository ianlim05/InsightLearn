/*
 * Author:      Foo Kim Chean
 * Description: Lesson management page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminManageLessons : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCourseDropdowns();
            LoadLessons();
        }
    }

    // Populate course dropdowns (filter + add + edit)
    private void LoadCourseDropdowns()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT course_id, course_name FROM Courses ORDER BY course_name", conn);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            // Filter dropdown — keep "All Courses" item already in markup
            foreach (DataRow row in dt.Rows)
            {
                ddlCourseFilter.Items.Add(new ListItem(
                    row["course_name"].ToString(),
                    row["course_id"].ToString()));
            }

            // Add lesson dropdown
            ddlAddCourse.Items.Clear();
            ddlAddCourse.Items.Add(new ListItem("-- Select Course --", ""));
            foreach (DataRow row in dt.Rows)
            {
                ddlAddCourse.Items.Add(new ListItem(
                    row["course_name"].ToString(),
                    row["course_id"].ToString()));
            }

            // Edit lesson dropdown
            ddlEditCourse.Items.Clear();
            foreach (DataRow row in dt.Rows)
            {
                ddlEditCourse.Items.Add(new ListItem(
                    row["course_name"].ToString(),
                    row["course_id"].ToString()));
            }
        }
    }

    private void LoadLessons()
    {
        string search   = txtSearch.Text.Trim();
        string courseId = ddlCourseFilter.SelectedValue;
        string connStr  = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            string sql = @"
                SELECT l.lesson_id, l.lesson_title, l.video_url, c.course_name
                FROM Lessons l
                INNER JOIN Courses c ON l.course_id = c.course_id
                WHERE 1=1 ";

            if (!string.IsNullOrEmpty(courseId))
                sql += " AND l.course_id = @cid ";
            if (!string.IsNullOrEmpty(search))
                sql += " AND l.lesson_title LIKE @search ";

            sql += " ORDER BY l.lesson_id ASC";

            SqlCommand cmd = new SqlCommand(sql, conn);

            if (!string.IsNullOrEmpty(courseId))
                cmd.Parameters.AddWithValue("@cid",    int.Parse(courseId));
            if (!string.IsNullOrEmpty(search))
                cmd.Parameters.AddWithValue("@search", "%" + search + "%");

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvLessons.DataSource = dt;
            gvLessons.DataBind();
        }

        LoadSummaryStats();
    }

    private void LoadSummaryStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons", conn);
            litCountLessons.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons WHERE video_url IS NOT NULL AND video_url <> ''", conn);
            litCountWithVideo.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Courses", conn);
            litCountCourses.Text = cmd.ExecuteScalar().ToString();
        }
    }

    protected void ddlCourseFilter_Changed(object sender, EventArgs e)
    {
        gvLessons.PageIndex = 0;
        LoadLessons();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvLessons.PageIndex = 0;
        LoadLessons();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlCourseFilter.SelectedIndex = 0;
        gvLessons.PageIndex = 0;
        LoadLessons();
    }

    protected void gvLessons_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvLessons.PageIndex = e.NewPageIndex;
        LoadLessons();
    }

    protected void btnShowAdd_Click(object sender, EventArgs e)
    {
        pnlAddLesson.Visible  = true;
        pnlEditLesson.Visible = false;
        txtAddTitle.Text      = "";
        txtAddContent.Text    = "";
        txtAddVideoUrl.Text   = "";
        ddlAddCourse.SelectedIndex = 0;
    }

    protected void btnCancelAdd_Click(object sender, EventArgs e)
    {
        pnlAddLesson.Visible = false;
    }

    protected void btnAddLesson_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int courseId    = int.Parse(ddlAddCourse.SelectedValue);
        string title    = txtAddTitle.Text.Trim();
        string content  = txtAddContent.Text.Trim();
        string videoUrl = txtAddVideoUrl.Text.Trim();

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES (@cid, @title, @content, @video)",
                conn);
            cmd.Parameters.AddWithValue("@cid",     courseId);
            cmd.Parameters.AddWithValue("@title",   title);
            cmd.Parameters.AddWithValue("@content", content);
            cmd.Parameters.AddWithValue("@video",   string.IsNullOrEmpty(videoUrl) ? (object)DBNull.Value : videoUrl);
            cmd.ExecuteNonQuery();
        }

        pnlAddLesson.Visible = false;
        ShowMessage("&#10003; Lesson added successfully!", true);
        LoadLessons();
    }

    protected void gvLessons_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int lessonId = int.Parse(e.CommandArgument.ToString());

        if (e.CommandName == "EditLesson")
        {
            LoadLessonForEdit(lessonId);
        }
        else if (e.CommandName == "DeleteLesson")
        {
            DeleteLesson(lessonId);
        }
    }

    private void LoadLessonForEdit(int lessonId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT lesson_id, course_id, lesson_title, lesson_content, video_url FROM Lessons WHERE lesson_id = @lid",
                conn);
            cmd.Parameters.AddWithValue("@lid", lessonId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                hdnEditLessonId.Value    = reader["lesson_id"].ToString();
                txtEditTitle.Text        = reader["lesson_title"].ToString();
                txtEditContent.Text      = reader["lesson_content"].ToString();
                txtEditVideoUrl.Text     = reader["video_url"] != DBNull.Value ? reader["video_url"].ToString() : "";
                ddlEditCourse.SelectedValue = reader["course_id"].ToString();
            }
        }

        pnlEditLesson.Visible = true;
        pnlAddLesson.Visible  = false;
    }

    protected void btnSaveEdit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int lessonId    = int.Parse(hdnEditLessonId.Value);
        int courseId    = int.Parse(ddlEditCourse.SelectedValue);
        string title    = txtEditTitle.Text.Trim();
        string content  = txtEditContent.Text.Trim();
        string videoUrl = txtEditVideoUrl.Text.Trim();

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "UPDATE Lessons SET course_id=@cid, lesson_title=@title, lesson_content=@content, video_url=@video WHERE lesson_id=@lid",
                conn);
            cmd.Parameters.AddWithValue("@cid",     courseId);
            cmd.Parameters.AddWithValue("@title",   title);
            cmd.Parameters.AddWithValue("@content", content);
            cmd.Parameters.AddWithValue("@video",   string.IsNullOrEmpty(videoUrl) ? (object)DBNull.Value : videoUrl);
            cmd.Parameters.AddWithValue("@lid",     lessonId);
            cmd.ExecuteNonQuery();
        }

        pnlEditLesson.Visible = false;
        ShowMessage("&#10003; Lesson updated successfully!", true);
        LoadLessons();
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        pnlEditLesson.Visible = false;
    }

    private void DeleteLesson(int lessonId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Lessons WHERE lesson_id = @lid", conn);
            cmd.Parameters.AddWithValue("@lid", lessonId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("&#10003; Lesson deleted successfully.", true);
        LoadLessons();
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text     = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible  = true;
    }
}
