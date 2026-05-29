/*
 * Author:      Oswald Loh Kar Tzun
 * Description: Admin analytics dashboard (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

public partial class AdminDashboard : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            litAdminName.Text = Server.HtmlEncode(
                Session["UserName"] != null ? Session["UserName"].ToString() : "Admin");
            LoadDashboardStats();
            LoadRecentEnrollments();
            LoadTopCourses();
        }
    }

    private void LoadDashboardStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE role = 'student'", conn);
            litTotalStudents.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Courses", conn);
            litTotalCourses.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Quizzes", conn);
            litTotalQuizzes.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Enrollment", conn);
            litEnrollments.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons", conn);
            litTotalLessons.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Quiz_Attempts", conn);
            litQuizAttempts.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT ISNULL(CAST(AVG(CAST(score AS FLOAT)) AS INT), 0) FROM Quiz_Attempts", conn);
            litAvgScore.Text = cmd.ExecuteScalar().ToString();
        }
    }

    private void LoadRecentEnrollments()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 8
                    u.name,
                    c.course_name,
                    e.enrolled_date
                FROM Enrollment e
                INNER JOIN Users u   ON e.user_id   = u.user_id
                INNER JOIN Courses c ON e.course_id = c.course_id
                ORDER BY e.enrollment_id DESC", conn);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                rptRecentEnrollments.DataSource = dt;
                rptRecentEnrollments.DataBind();
                lblNoEnrollments.Visible = false;
            }
            else
            {
                rptRecentEnrollments.Visible = false;
                lblNoEnrollments.Visible = true;
            }
        }
    }

    private void LoadTopCourses()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 5
                    c.course_name,
                    COUNT(e.enrollment_id) AS enroll_count
                FROM Courses c
                LEFT JOIN Enrollment e ON c.course_id = e.course_id
                GROUP BY c.course_id, c.course_name
                ORDER BY enroll_count DESC", conn);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            rptTopCourses.DataSource = dt;
            rptTopCourses.DataBind();
        }
    }

    // Returns enrollment trend data as JSON for the bar chart (last 6 months)
    protected string GetEnrollmentTrendJson()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        var labels = new System.Collections.Generic.List<string>();
        var values = new System.Collections.Generic.List<int>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Count enrollments per month for last 6 months
                SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        FORMAT(enrolled_date, 'MMM yyyy') AS month_label,
                        YEAR(enrolled_date)               AS yr,
                        MONTH(enrolled_date)              AS mo,
                        COUNT(*)                          AS cnt
                    FROM Enrollment
                    WHERE enrolled_date >= DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
                    GROUP BY FORMAT(enrolled_date, 'MMM yyyy'), YEAR(enrolled_date), MONTH(enrolled_date)
                    ORDER BY yr, mo", conn);

                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    labels.Add(reader["month_label"].ToString());
                    values.Add(Convert.ToInt32(reader["cnt"]));
                }
            }
        }
        catch { }

        if (labels.Count == 0)
            return "{}";

        var sb = new StringBuilder();
        sb.Append("{\"labels\":[");
        for (int i = 0; i < labels.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append("\"").Append(labels[i]).Append("\"");
        }
        sb.Append("],\"values\":[");
        for (int i = 0; i < values.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append(values[i]);
        }
        sb.Append("]}");
        return sb.ToString();
    }
}
