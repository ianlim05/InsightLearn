/*
 * Author:      Oswald Loh Kar Tzun
 * Description: Question bank management page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminManageQuestions : Page
{
    private int quizId = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Admin only
        if (Session["UserId"] == null || Session["UserType"].ToString() != "admin")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        int.TryParse(Request.QueryString["quizId"], out quizId);
        if (quizId <= 0)
        {
            Response.Redirect("AdminManageQuizzes.aspx");
            return;
        }

        // Always load quiz title so the header shows correctly on every postback
        LoadQuizTitle();

        if (!IsPostBack)
        {
            LoadQuestions();
        }
    }

    // Load and display the quiz title in the page header
    private void LoadQuizTitle()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT quiz_title FROM Quizzes WHERE quiz_id = @qid", conn);
            cmd.Parameters.AddWithValue("@qid", quizId);
            object title = cmd.ExecuteScalar();

            if (title != null)
            {
                litQuizTitleSub.Text = Server.HtmlEncode(title.ToString());
            }
            else
            {
                // Quiz does not exist — redirect back
                Response.Redirect("AdminManageQuizzes.aspx");
            }
        }
    }

    // Load all questions for this quiz and bind to the GridView
    private void LoadQuestions()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                @"SELECT question_id, question_text, option_a, option_b, option_c, option_d, correct_answer
                  FROM Questions
                  WHERE quiz_id = @qid
                  ORDER BY question_id",
                conn);
            cmd.Parameters.AddWithValue("@qid", quizId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            litQCount.Text         = dt.Rows.Count.ToString();
            gvQuestions.DataSource = dt;
            gvQuestions.DataBind();
        }
    }

    // ---- Paging ----

    protected void gvQuestions_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvQuestions.PageIndex = e.NewPageIndex;
        LoadQuestions();
    }

    // ---- Add Question ----

    protected void btnShowAddQuestion_Click(object sender, EventArgs e)
    {
        pnlAddQuestion.Visible  = true;
        pnlEditQuestion.Visible = false;
        txtAddQText.Text = "";
        txtAddOptA.Text  = "";
        txtAddOptB.Text  = "";
        txtAddOptC.Text  = "";
        txtAddOptD.Text  = "";
        ddlAddCorrect.SelectedIndex = 0;
    }

    protected void btnCancelAddQ_Click(object sender, EventArgs e)
    {
        pnlAddQuestion.Visible = false;
    }

    protected void btnAddQuestion_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string qText   = txtAddQText.Text.Trim();
        string optA    = txtAddOptA.Text.Trim();
        string optB    = txtAddOptB.Text.Trim();
        string optC    = txtAddOptC.Text.Trim();
        string optD    = txtAddOptD.Text.Trim();
        string correct = ddlAddCorrect.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer)
                VALUES (@qid, @text, @a, @b, @c, @d, @ans)", conn);
            cmd.Parameters.AddWithValue("@qid",  quizId);
            cmd.Parameters.AddWithValue("@text", qText);
            cmd.Parameters.AddWithValue("@a",    optA);
            cmd.Parameters.AddWithValue("@b",    optB);
            cmd.Parameters.AddWithValue("@c",    optC);
            cmd.Parameters.AddWithValue("@d",    optD);
            cmd.Parameters.AddWithValue("@ans",  correct);
            cmd.ExecuteNonQuery();
        }

        pnlAddQuestion.Visible = false;
        ShowMessage("&#10003; Question added successfully!", true);
        gvQuestions.PageIndex = 0;
        LoadQuestions();
    }

    // ---- Edit Question ----

    protected void gvQuestions_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int questionId = int.Parse(e.CommandArgument.ToString());

        if (e.CommandName == "EditQ")
            LoadQuestionForEdit(questionId);
        else if (e.CommandName == "DeleteQ")
            DeleteQuestion(questionId);
    }

    private void LoadQuestionForEdit(int questionId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Questions WHERE question_id = @qid", conn);
            cmd.Parameters.AddWithValue("@qid", questionId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                hdnEditQuestionId.Value      = reader["question_id"].ToString();
                txtEditQText.Text            = reader["question_text"].ToString();
                txtEditOptA.Text             = reader["option_a"].ToString();
                txtEditOptB.Text             = reader["option_b"].ToString();
                txtEditOptC.Text             = reader["option_c"].ToString();
                txtEditOptD.Text             = reader["option_d"].ToString();
                ddlEditCorrect.SelectedValue = reader["correct_answer"].ToString();
            }
        }

        pnlEditQuestion.Visible = true;
        pnlAddQuestion.Visible  = false;
    }

    protected void btnSaveEditQ_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int questionId = int.Parse(hdnEditQuestionId.Value);
        string qText   = txtEditQText.Text.Trim();
        string optA    = txtEditOptA.Text.Trim();
        string optB    = txtEditOptB.Text.Trim();
        string optC    = txtEditOptC.Text.Trim();
        string optD    = txtEditOptD.Text.Trim();
        string correct = ddlEditCorrect.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Questions SET
                    question_text  = @text,
                    option_a       = @a,
                    option_b       = @b,
                    option_c       = @c,
                    option_d       = @d,
                    correct_answer = @ans
                WHERE question_id  = @qid", conn);
            cmd.Parameters.AddWithValue("@text", qText);
            cmd.Parameters.AddWithValue("@a",    optA);
            cmd.Parameters.AddWithValue("@b",    optB);
            cmd.Parameters.AddWithValue("@c",    optC);
            cmd.Parameters.AddWithValue("@d",    optD);
            cmd.Parameters.AddWithValue("@ans",  correct);
            cmd.Parameters.AddWithValue("@qid",  questionId);
            cmd.ExecuteNonQuery();
        }

        pnlEditQuestion.Visible = false;
        ShowMessage("&#10003; Question updated successfully!", true);
        LoadQuestions();
    }

    protected void btnCancelEditQ_Click(object sender, EventArgs e)
    {
        pnlEditQuestion.Visible = false;
    }

    // ---- Delete Question ----

    private void DeleteQuestion(int questionId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Remove any recorded answers for this question first (FK constraint)
            SqlCommand delAnswers = new SqlCommand(
                "DELETE FROM Attempt_Answers WHERE question_id = @qid", conn);
            delAnswers.Parameters.AddWithValue("@qid", questionId);
            delAnswers.ExecuteNonQuery();

            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Questions WHERE question_id = @qid", conn);
            cmd.Parameters.AddWithValue("@qid", questionId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("&#10003; Question deleted successfully.", true);
        LoadQuestions();
    }

    // ---- Helper ----

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text     = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible  = true;
    }
}
