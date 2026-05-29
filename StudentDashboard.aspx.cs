/*
 * Author:      Oswald Loh Kar Tzun
 * Description: Student progress dashboard (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class StudentDashboard : Page
{
    // Chart data stored for rendering in JS
    private List<string> chartLabels = new List<string>();
    private List<int>    chartValues = new List<int>();

    protected void Page_Load(object sender, EventArgs e)
    {
        // Protect page — redirect non-students to login
        if (Session["UserType"] == null || Session["UserType"].ToString() != "student")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            int userId = int.Parse(Session["UserId"].ToString());
            lblWelcome.Text = Session["UserName"].ToString();

            LoadStats(userId);
            LoadMyCourses(userId);
            LoadQuizResults(userId);
            LoadAchievements(userId);
            LoadRecommendations(userId);
        }
    }

    protected void lbDashboardLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }

    // Load the 4 statistics cards from database
    private void LoadStats(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Courses enrolled
            SqlCommand cmd1 = new SqlCommand(
                @"SELECT COUNT(*)
                  FROM Enrollment e
                  INNER JOIN Courses c ON e.course_id = c.course_id
                  WHERE e.user_id = @uid AND c.published = 1", conn);
            cmd1.Parameters.AddWithValue("@uid", userId);
            lblCoursesEnrolled.Text = cmd1.ExecuteScalar().ToString();

            // Lessons completed
            SqlCommand cmd2 = new SqlCommand(
                @"SELECT COUNT(*)
                  FROM Lesson_Progress lp
                  INNER JOIN Lessons l ON lp.lesson_id = l.lesson_id
                  INNER JOIN Courses c ON l.course_id = c.course_id
                  WHERE lp.user_id = @uid AND lp.is_completed = 1 AND c.published = 1", conn);
            cmd2.Parameters.AddWithValue("@uid", userId);
            lblLessonsCompleted.Text = cmd2.ExecuteScalar().ToString();

            // Quizzes taken
            SqlCommand cmd3 = new SqlCommand(
                "SELECT COUNT(*) FROM Quiz_Attempts WHERE user_id = @uid", conn);
            cmd3.Parameters.AddWithValue("@uid", userId);
            int quizCount = (int)cmd3.ExecuteScalar();
            lblQuizzesTaken.Text = quizCount.ToString();

            // Average score
            SqlCommand cmd4 = new SqlCommand(
                "SELECT ISNULL(AVG(CAST(score AS FLOAT)), 0) FROM Quiz_Attempts WHERE user_id = @uid", conn);
            cmd4.Parameters.AddWithValue("@uid", userId);
            double avg = (double)cmd4.ExecuteScalar();
            lblAvgScore.Text = Math.Round(avg, 0).ToString();

            // Calculate learning streak (days in a row with quiz activity)
            // Simplified: count days in last 7 days with any attempt
            SqlCommand cmdStreak = new SqlCommand(
                "SELECT COUNT(DISTINCT CAST(attempt_date AS DATE)) FROM Quiz_Attempts " +
                "WHERE user_id = @uid AND attempt_date >= DATEADD(day, -7, GETDATE())", conn);
            cmdStreak.Parameters.AddWithValue("@uid", userId);
            int streak = (int)cmdStreak.ExecuteScalar();
            lblStreak.Text = streak.ToString();
        }
    }

    // Load enrolled courses with progress percentage
    private void LoadMyCourses(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Get enrolled courses with total lessons and completed lessons counts
            string sql = @"
                SELECT
                    c.course_id,
                    c.course_name,
                    (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) AS total_lessons,
                    (SELECT COUNT(*) FROM Lesson_Progress lp
                        INNER JOIN Lessons l2 ON lp.lesson_id = l2.lesson_id
                        WHERE lp.user_id = @uid AND lp.is_completed = 1 AND l2.course_id = c.course_id) AS completed_lessons,
                    (SELECT TOP 1 lesson_title FROM Lessons
                        WHERE course_id = c.course_id
                        AND lesson_id NOT IN (
                            SELECT lp2.lesson_id FROM Lesson_Progress lp2
                            WHERE lp2.user_id = @uid AND lp2.is_completed = 1
                        )
                        ORDER BY lesson_id) AS next_lesson
                FROM Courses c
                INNER JOIN Enrollment e ON c.course_id = e.course_id
                WHERE e.user_id = @uid
                AND c.published = 1
                ORDER BY e.enrolled_date DESC";

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@uid", userId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            // Calculate progress percentage
            dt.Columns.Add("progress_pct", typeof(int));

            foreach (DataRow row in dt.Rows)
            {
                int total = (int)row["total_lessons"];
                int done  = (int)row["completed_lessons"];
                row["progress_pct"] = total > 0 ? (done * 100 / total) : 0;
            }

            if (dt.Rows.Count > 0)
            {
                rptMyCourses.DataSource = dt;
                rptMyCourses.DataBind();
                pnlNoCourses.Visible = false;
            }
            else
            {
                rptMyCourses.Visible = false;
                pnlNoCourses.Visible = true;
            }
        }
    }

    // Load recent quiz attempts
    private void LoadQuizResults(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // --- GridView: 5 most recent individual attempts (newest first) ---
            string gridSql = @"
                SELECT TOP 5
                    c.course_name,
                    q.quiz_title,
                    qa.attempt_date,
                    qa.score
                FROM Quiz_Attempts qa
                INNER JOIN Quizzes q ON qa.quiz_id = q.quiz_id
                INNER JOIN Courses c ON q.course_id = c.course_id
                WHERE qa.user_id = @uid
                ORDER BY qa.attempt_date DESC";

            SqlCommand gridCmd = new SqlCommand(gridSql, conn);
            gridCmd.Parameters.AddWithValue("@uid", userId);

            SqlDataAdapter da = new SqlDataAdapter(gridCmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvQuizResults.DataSource = dt;
            gvQuizResults.DataBind();

            // --- Chart: last 5 calendar days, one bar per day ---
            // Every day in the window is always shown.
            // Days with no quiz attempt get a value of 0 (displayed as an empty bar).
            DateTime today = DateTime.Today;

            string chartSql = @"
                SELECT
                    CAST(attempt_date AS DATE)          AS attempt_day,
                    ROUND(AVG(CAST(score AS FLOAT)), 0) AS avg_score
                FROM Quiz_Attempts
                WHERE user_id = @uid
                  AND attempt_date >= @startDate
                GROUP BY CAST(attempt_date AS DATE)";

            SqlCommand chartCmd = new SqlCommand(chartSql, conn);
            chartCmd.Parameters.AddWithValue("@uid",       userId);
            chartCmd.Parameters.AddWithValue("@startDate", today.AddDays(-4));

            // Read DB results into a dictionary keyed by calendar date
            var scoreByDay = new Dictionary<DateTime, int>();
            SqlDataReader chartReader = chartCmd.ExecuteReader();
            while (chartReader.Read())
            {
                DateTime day = Convert.ToDateTime(chartReader["attempt_day"]);
                scoreByDay[day] = Convert.ToInt32(chartReader["avg_score"]);
            }
            chartReader.Close();

            // Always emit exactly 5 bars: 4 days ago → today (oldest left, newest right)
            for (int d = 4; d >= 0; d--)
            {
                DateTime day = today.AddDays(-d);
                chartLabels.Add(day.ToString("dd MMM"));
                chartValues.Add(scoreByDay.ContainsKey(day) ? scoreByDay[day] : 0);
            }
        }
    }

    // Build achievements based on user activity
    private void LoadAchievements(int userId)
    {
        var achievements = new List<object>();

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Check if user has completed at least one course
            SqlCommand cmd1 = new SqlCommand(
                @"SELECT COUNT(*) FROM Enrollment e WHERE e.user_id = @uid
                  AND (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = e.course_id) =
                      (SELECT COUNT(*) FROM Lesson_Progress lp
                       INNER JOIN Lessons l2 ON lp.lesson_id = l2.lesson_id
                       WHERE lp.user_id = @uid AND lp.is_completed = 1 AND l2.course_id = e.course_id)", conn);
            cmd1.Parameters.AddWithValue("@uid", userId);
            int completedCourses = (int)cmd1.ExecuteScalar();

            if (completedCourses > 0)
                achievements.Add(new { icon = "&#127941;", color = "#ECFDF5", title = "First Course", desc = "Completed your first course" });

            // Check if user scored 100% on any quiz
            SqlCommand cmd2 = new SqlCommand(
                "SELECT COUNT(*) FROM Quiz_Attempts WHERE user_id = @uid AND score = 100", conn);
            cmd2.Parameters.AddWithValue("@uid", userId);
            int perfect = (int)cmd2.ExecuteScalar();

            if (perfect > 0)
                achievements.Add(new { icon = "&#127881;", color = "#FFF7ED", title = "Perfect Score", desc = "Got 100% on a quiz" });

            // Check quiz streak
            SqlCommand cmd3 = new SqlCommand(
                "SELECT COUNT(*) FROM Quiz_Attempts WHERE user_id = @uid", conn);
            cmd3.Parameters.AddWithValue("@uid", userId);
            int totalAttempts = (int)cmd3.ExecuteScalar();

            if (totalAttempts >= 3)
                achievements.Add(new { icon = "&#128293;", color = "#FFFBEB", title = "Week Warrior", desc = "Completed 3+ quizzes" });

            // First enrollment
            SqlCommand cmd4 = new SqlCommand(
                "SELECT COUNT(*) FROM Enrollment WHERE user_id = @uid", conn);
            cmd4.Parameters.AddWithValue("@uid", userId);
            int enrolled = (int)cmd4.ExecuteScalar();

            if (enrolled > 0)
                achievements.Add(new { icon = "&#128218;", color = "#EEF2FF", title = "Learner", desc = "Enrolled in first course" });
        }

        if (achievements.Count == 0)
            achievements.Add(new { icon = "&#128736;", color = "#F1F5F9", title = "Just Starting", desc = "Complete courses to earn badges!" });

        rptAchievements.DataSource = achievements;
        rptAchievements.DataBind();
    }

    // Load course recommendations — unenrolled courses first, then enrolled-but-incomplete as fallback
    private void LoadRecommendations(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Primary: courses the user has NOT enrolled in yet
            string sql = @"
                SELECT TOP 2
                    course_id,
                    course_name,
                    'New course you haven''t tried yet' AS rec_reason
                FROM Courses
                WHERE published = 1
                AND course_id NOT IN (SELECT course_id FROM Enrollment WHERE user_id = @uid)
                ORDER BY NEWID()";

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@uid", userId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            // Fallback: enrolled courses with incomplete lessons
            if (dt.Rows.Count == 0)
            {
                string fallbackSql = @"
                    SELECT TOP 2
                        c.course_id,
                        c.course_name,
                        'Continue where you left off' AS rec_reason
                    FROM Courses c
                    INNER JOIN Enrollment e ON c.course_id = e.course_id
                    WHERE e.user_id = @uid
                    AND c.published = 1
                    AND (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) >
                        (SELECT COUNT(*) FROM Lesson_Progress lp
                         INNER JOIN Lessons l2 ON lp.lesson_id = l2.lesson_id
                         WHERE lp.user_id = @uid AND lp.is_completed = 1 AND l2.course_id = c.course_id)
                    ORDER BY NEWID()";

                SqlCommand fallbackCmd = new SqlCommand(fallbackSql, conn);
                fallbackCmd.Parameters.AddWithValue("@uid", userId);
                SqlDataAdapter fallbackDa = new SqlDataAdapter(fallbackCmd);
                fallbackDa.Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                rptRecommendations.DataSource = dt;
                rptRecommendations.DataBind();
                pnlNoRec.Visible = false;
            }
            else
            {
                rptRecommendations.Visible = false;
                pnlNoRec.Visible = true;
            }
        }
    }

    // Return JSON string for chart rendering
    protected string GetChartDataJson()
    {
        if (chartLabels.Count == 0) return "{}";

        var labels = new System.Text.StringBuilder("[");
        var values = new System.Text.StringBuilder("[");

        for (int i = 0; i < chartLabels.Count; i++)
        {
            labels.Append("\"" + chartLabels[i] + "\"");
            values.Append(chartValues[i]);
            if (i < chartLabels.Count - 1) { labels.Append(","); values.Append(","); }
        }
        labels.Append("]");
        values.Append("]");

        return "{\"labels\":" + labels + ",\"values\":" + values + "}";
    }

    // Continue button clicked on enrolled course
    protected void rptMyCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "Continue")
        {
            int courseId = int.Parse(e.CommandArgument.ToString());
            Response.Redirect("Lesson.aspx?courseId=" + courseId);
        }
    }
}
