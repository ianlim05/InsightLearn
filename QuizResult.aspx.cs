/*
 * Author:      Chan Kar Jun
 * Description: Quiz result display page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

public partial class QuizResult : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        if (Session["QuizResult_Score"] == null)
        {
            Response.Redirect("StudentDashboard.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadResult();
        }
    }

    private void LoadResult()
    {
        int score     = (int)Session["QuizResult_Score"];
        int correct   = (int)Session["QuizResult_Correct"];
        int total     = (int)Session["QuizResult_Total"];
        string title  = Session["QuizResult_QuizTitle"] != null ? Session["QuizResult_QuizTitle"].ToString() : "Quiz";
        int attemptId = Session["QuizResult_AttemptId"] != null ? (int)Session["QuizResult_AttemptId"] : 0;

        litQuizTitle.Text = Server.HtmlEncode(title);
        litScore.Text     = score.ToString();
        litCorrect.Text   = correct.ToString();
        litWrong.Text     = (total - correct).ToString();
        litTotal.Text     = total.ToString();

        bool passed = score >= 70;
        scoreCircle.Attributes["class"] = "result-score-circle " + (passed ? "pass" : "fail");

        lblPassFail.Text    = passed ? "&#10003;&nbsp; Passed!" : "&#10007;&nbsp; Not Passed";
        lblPassFail.CssClass = "result-pass-badge " + (passed ? "pass" : "fail");

        if (passed)
            lblEncouragement.Text = "&#127881; Congratulations! You passed this quiz.";
        else
            lblEncouragement.Text = "";

        if (attemptId > 0)
        {
            int quizId = GetQuizIdFromAttempt(attemptId);
            if (quizId > 0)
                hlRetakeQuiz.NavigateUrl = "Quiz.aspx?quizId=" + quizId;
            else
                hlRetakeQuiz.Visible = false;

            LoadQuestionReview(attemptId);
        }
        else
        {
            hlRetakeQuiz.Visible = false;
        }

        // Clear session data after reading
        Session.Remove("QuizResult_Score");
        Session.Remove("QuizResult_Correct");
        Session.Remove("QuizResult_Total");
        Session.Remove("QuizResult_QuizTitle");
        Session.Remove("QuizResult_AttemptId");
    }

    private int GetQuizIdFromAttempt(int attemptId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand("SELECT quiz_id FROM Quiz_Attempts WHERE attempt_id = @aid", conn);
            cmd.Parameters.AddWithValue("@aid", attemptId);
            object result = cmd.ExecuteScalar();
            return result != null ? (int)result : 0;
        }
    }

    private void LoadQuestionReview(int attemptId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(@"
                SELECT
                    q.question_id,
                    q.question_text,
                    q.option_a, q.option_b, q.option_c, q.option_d,
                    q.correct_answer,
                    ISNULL(aa.selected_answer, '') AS selected_answer
                FROM Quiz_Attempts qa
                INNER JOIN Quizzes qz ON qa.quiz_id = qz.quiz_id
                INNER JOIN Questions q  ON q.quiz_id = qz.quiz_id
                LEFT JOIN Attempt_Answers aa ON aa.attempt_id = @aid AND aa.question_id = q.question_id
                WHERE qa.attempt_id = @aid
                ORDER BY q.question_id", conn);
            cmd.Parameters.AddWithValue("@aid", attemptId);

            SqlDataReader reader = cmd.ExecuteReader();
            var reviewList = new List<ReviewQuestion>();
            int num = 1;

            while (reader.Read())
            {
                string selected = reader["selected_answer"].ToString();
                string correct  = reader["correct_answer"].ToString();

                reviewList.Add(new ReviewQuestion
                {
                    QuestionNum    = num++,
                    QuestionText   = reader["question_text"].ToString(),
                    OptionA        = reader["option_a"].ToString(),
                    OptionB        = reader["option_b"].ToString(),
                    OptionC        = reader["option_c"].ToString(),
                    OptionD        = reader["option_d"].ToString(),
                    CorrectAnswer  = correct,
                    SelectedAnswer = selected,
                    IsCorrect      = !string.IsNullOrEmpty(selected) && selected == correct
                });
            }

            rptReview.DataSource = reviewList;
            rptReview.DataBind();
        }
    }

    // Builds a clean option HTML block — avoids complex inline ternary chains in .aspx
    protected string BuildOptionHtml(string letter, string text, string selected, string correct)
    {
        string cssClass = "review-option";
        string tag = "";

        if (selected == letter)
        {
            cssClass += selected == correct ? " option-correct" : " option-wrong";
            tag = "<span class='your-answer-tag'>Your Answer</span>";
        }
        else if (correct == letter && selected != correct)
        {
            cssClass += " option-correct-show";
            tag = "<span class='correct-answer-tag'>Correct</span>";
        }

        return string.Format(
            "<div class='{0}'><strong>{1}.</strong> {2} {3}</div>",
            cssClass, letter, HttpUtility.HtmlEncode(text), tag);
    }
}

public class ReviewQuestion
{
    public int    QuestionNum    { get; set; }
    public string QuestionText   { get; set; }
    public string OptionA        { get; set; }
    public string OptionB        { get; set; }
    public string OptionC        { get; set; }
    public string OptionD        { get; set; }
    public string CorrectAnswer  { get; set; }
    public string SelectedAnswer { get; set; }
    public bool   IsCorrect      { get; set; }
}
