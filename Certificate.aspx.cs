/*
 * Author:      Foo Kim Chean
 * Description: Course completion certificate page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Certificate : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Protect page — only logged-in students
        if (Session["UserType"] == null || Session["UserType"].ToString() != "student")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            int userId = int.Parse(Session["UserId"].ToString());
            LoadCertificates(userId);
        }
    }

    private void LoadCertificates(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // A course is "completed" when:
            //   the number of completed lessons for the user equals the total lessons in the course,
            //   and the course has at least 1 lesson.
            // We use enrolled_date as the completion date since Lesson_Progress has no timestamp.
            string sql = @"
                SELECT
                    c.course_id,
                    c.course_name,
                    c.category,
                    (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) AS lesson_count,
                    e.enrolled_date AS completion_date
                FROM Courses c
                INNER JOIN Enrollment e ON c.course_id = e.course_id
                WHERE e.user_id = @uid
                AND (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) > 0
                AND (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) =
                    (SELECT COUNT(*) FROM Lesson_Progress lp
                     INNER JOIN Lessons l2 ON lp.lesson_id = l2.lesson_id
                     WHERE lp.user_id = @uid AND lp.is_completed = 1 AND l2.course_id = c.course_id)
                ORDER BY e.enrolled_date DESC";

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@uid", userId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                rptCerts.DataSource = dt;
                rptCerts.DataBind();

                // Inject the student name into each repeater item
                string studentName = Session["UserName"] != null ? Session["UserName"].ToString() : "Student";
                foreach (RepeaterItem item in rptCerts.Items)
                {
                    Label lbl = (Label)item.FindControl("lblStudentName");
                    if (lbl != null) lbl.Text = studentName;
                }

                pnlCerts.Visible   = true;
                pnlNoCerts.Visible = false;
            }
            else
            {
                pnlCerts.Visible   = false;
                pnlNoCerts.Visible = true;
            }
        }
    }
}
