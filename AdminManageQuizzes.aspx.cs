/*
 * Author:      Chan Kar Jun
 * Description: Quiz management page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminManageQuizzes : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCourseDropdowns();
            LoadQuizzes();
        }
    }

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

            foreach (DataRow row in dt.Rows)
            {
                string name = row["course_name"].ToString();
                string id   = row["course_id"].ToString();

                ddlCourseFilter.Items.Add(new ListItem(name, id));
                ddlAddQuizCourse.Items.Add(new ListItem(name, id));
                ddlEditQuizCourse.Items.Add(new ListItem(name, id));
            }
        }
    }

    private void LoadQuizzes()
    {
        string search   = txtQuizSearch.Text.Trim();
        string courseId = ddlCourseFilter.SelectedValue;
        string connStr  = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            string sql = @"
                SELECT
                    q.quiz_id,
                    q.quiz_title,
                    c.course_name,
                    (SELECT COUNT(*) FROM Questions qu WHERE qu.quiz_id = q.quiz_id) AS question_count
                FROM Quizzes q
                INNER JOIN Courses c ON q.course_id = c.course_id
                WHERE 1=1 ";

            if (!string.IsNullOrEmpty(courseId))
                sql += " AND q.course_id = @cid ";
            if (!string.IsNullOrEmpty(search))
                sql += " AND q.quiz_title LIKE @search ";

            sql += " ORDER BY q.quiz_id";

            SqlCommand cmd = new SqlCommand(sql, conn);

            if (!string.IsNullOrEmpty(courseId))
                cmd.Parameters.AddWithValue("@cid",    int.Parse(courseId));
            if (!string.IsNullOrEmpty(search))
                cmd.Parameters.AddWithValue("@search", "%" + search + "%");

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvQuizzes.DataSource = dt;
            gvQuizzes.DataBind();
        }

        LoadSummaryStats();
    }

    private void LoadSummaryStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Quizzes", conn);
            litCountQuizzes.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Questions", conn);
            litCountQuestions.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand(
                "SELECT ISNULL(COUNT(*) / NULLIF(COUNT(DISTINCT quiz_id), 0), 0) FROM Questions", conn);
            litAvgQuestions.Text = cmd.ExecuteScalar().ToString();
        }
    }

    protected void ddlCourseFilter_Changed(object sender, EventArgs e)
    {
        gvQuizzes.PageIndex = 0;
        LoadQuizzes();
    }

    protected void btnQuizSearch_Click(object sender, EventArgs e)
    {
        gvQuizzes.PageIndex = 0;
        LoadQuizzes();
    }

    protected void btnQuizClear_Click(object sender, EventArgs e)
    {
        txtQuizSearch.Text = "";
        ddlCourseFilter.SelectedIndex = 0;
        gvQuizzes.PageIndex = 0;
        LoadQuizzes();
    }

    protected void gvQuizzes_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvQuizzes.PageIndex = e.NewPageIndex;
        LoadQuizzes();
    }

    // ---- Quiz CRUD ----

    protected void btnShowAddQuiz_Click(object sender, EventArgs e)
    {
        pnlAddQuiz.Visible  = true;
        pnlEditQuiz.Visible = false;
        txtAddQuizTitle.Text = "";
        ddlAddQuizCourse.SelectedIndex = 0;
    }

    protected void btnCancelAddQuiz_Click(object sender, EventArgs e)
    {
        pnlAddQuiz.Visible = false;
    }

    protected void btnAddQuiz_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string title   = txtAddQuizTitle.Text.Trim();
        int courseId   = int.Parse(ddlAddQuizCourse.SelectedValue);
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Quizzes WHERE course_id = @cid", conn);
            checkCmd.Parameters.AddWithValue("@cid", courseId);
            if ((int)checkCmd.ExecuteScalar() > 0)
            {
                ShowMessage("This course already has a quiz. Edit or delete it first.", false);
                return;
            }

            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Quizzes (quiz_title, course_id) VALUES (@title, @cid)", conn);
            cmd.Parameters.AddWithValue("@title", title);
            cmd.Parameters.AddWithValue("@cid",   courseId);
            cmd.ExecuteNonQuery();
        }

        pnlAddQuiz.Visible = false;
        ShowMessage("Quiz added successfully!", true);
        LoadQuizzes();
    }

    protected void gvQuizzes_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int quizId = int.Parse(e.CommandArgument.ToString());

        if (e.CommandName == "ManageQ")
        {
            // Navigate to the dedicated questions management page
            Response.Redirect("AdminManageQuestions.aspx?quizId=" + quizId);
        }
        else if (e.CommandName == "EditQuiz")
        {
            LoadQuizForEdit(quizId);
        }
        else if (e.CommandName == "DeleteQuiz")
        {
            DeleteQuiz(quizId);
        }
    }

    private void LoadQuizForEdit(int quizId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT quiz_id, quiz_title, course_id FROM Quizzes WHERE quiz_id = @qid", conn);
            cmd.Parameters.AddWithValue("@qid", quizId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                hdnEditQuizId.Value             = reader["quiz_id"].ToString();
                txtEditQuizTitle.Text           = reader["quiz_title"].ToString();
                ddlEditQuizCourse.SelectedValue = reader["course_id"].ToString();
            }
        }

        pnlEditQuiz.Visible = true;
        pnlAddQuiz.Visible  = false;
    }

    protected void btnSaveEditQuiz_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int quizId    = int.Parse(hdnEditQuizId.Value);
        string title  = txtEditQuizTitle.Text.Trim();
        int courseId  = int.Parse(ddlEditQuizCourse.SelectedValue);
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "UPDATE Quizzes SET quiz_title=@title, course_id=@cid WHERE quiz_id=@qid", conn);
            cmd.Parameters.AddWithValue("@title", title);
            cmd.Parameters.AddWithValue("@cid",   courseId);
            cmd.Parameters.AddWithValue("@qid",   quizId);
            cmd.ExecuteNonQuery();
        }

        pnlEditQuiz.Visible = false;
        ShowMessage("&#10003; Quiz updated successfully!", true);
        LoadQuizzes();
    }

    protected void btnCancelEditQuiz_Click(object sender, EventArgs e)
    {
        pnlEditQuiz.Visible = false;
    }

    private void DeleteQuiz(int quizId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            // FK cascade deletes Questions, Quiz_Attempts, Attempt_Answers
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Quizzes WHERE quiz_id = @qid", conn);
            cmd.Parameters.AddWithValue("@qid", quizId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("&#10003; Quiz deleted successfully.", true);
        LoadQuizzes();
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text     = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible  = true;
    }
}
