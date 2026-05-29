/*
 * Author:      Chan Kar Jun
 * Description: Student quiz-taking page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// Stores one quiz question with its options
[Serializable]
public class QuizQuestion
{
    public int    QuestionId   { get; set; }
    public string QuestionText { get; set; }
    public string OptionA      { get; set; }
    public string OptionB      { get; set; }
    public string OptionC      { get; set; }
    public string OptionD      { get; set; }
    public string CorrectAnswer { get; set; }
}

public partial class Quiz : Page
{
    // Session keys for quiz state
    private const string SESSION_QUESTIONS = "QuizQuestions";
    private const string SESSION_ANSWERS   = "QuizAnswers";
    private const string SESSION_FLAGGED   = "QuizFlagged";
    private const string SESSION_QUIZ_ID   = "CurrentQuizId";

    private int currentQ = 0;
    private List<QuizQuestion> questions;
    private Dictionary<int, string> answers;
    private HashSet<int> flagged;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Must be logged in
        if (Session["UserId"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        // Students only — admins have no business taking quizzes
        if (Session["UserType"] != null && Session["UserType"].ToString() == "admin")
        {
            Response.Redirect("AdminDashboard.aspx");
            return;
        }

        if (!IsPostBack)
        {
            int quizId = 0;
            int.TryParse(Request.QueryString["quizId"], out quizId);

            if (quizId <= 0)
            {
                Response.Redirect("CourseList.aspx");
                return;
            }

            // Enrollment check — student must be enrolled in this quiz's course
            int userId = int.Parse(Session["UserId"].ToString());
            if (!IsEnrolledInQuizCourse(quizId, userId))
            {
                Response.Redirect("CourseList.aspx");
                return;
            }

            // Load questions from DB into session
            LoadQuizFromDB(quizId);
            Session[SESSION_QUIZ_ID] = quizId;
            Session[SESSION_ANSWERS] = new Dictionary<int, string>();
            Session[SESSION_FLAGGED] = new HashSet<int>();
            hdnCurrentQ.Value = "0";
        }

        // Load state from session
        questions = Session[SESSION_QUESTIONS] as List<QuizQuestion>;
        answers   = Session[SESSION_ANSWERS]   as Dictionary<int, string>;
        flagged   = Session[SESSION_FLAGGED]   as HashSet<int>;

        if (questions == null || questions.Count == 0)
        {
            lblError.Text = "No questions found for this quiz.";
            lblError.Visible = true;
            pnlQuiz.Visible = false;
            return;
        }

        int.TryParse(hdnCurrentQ.Value, out currentQ);
        if (currentQ < 0) currentQ = 0;
        if (currentQ >= questions.Count) currentQ = questions.Count - 1;

        DisplayCurrentQuestion();
    }

    // Verify the student is enrolled in the course that owns this quiz
    private bool IsEnrolledInQuizCourse(int quizId, int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(*) FROM Enrollment e
                  INNER JOIN Quizzes q ON q.course_id = e.course_id
                  WHERE q.quiz_id = @qid AND e.user_id = @uid", conn);
            cmd.Parameters.AddWithValue("@qid", quizId);
            cmd.Parameters.AddWithValue("@uid", userId);
            return (int)cmd.ExecuteScalar() > 0;
        }
    }

    // Load all questions from database and store in session
    private void LoadQuizFromDB(int quizId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Get quiz title
            SqlCommand titleCmd = new SqlCommand(@"
                SELECT q.quiz_title, q.course_id, c.published
                FROM Quizzes q
                INNER JOIN Courses c ON q.course_id = c.course_id
                WHERE q.quiz_id = @qid", conn);
            titleCmd.Parameters.AddWithValue("@qid", quizId);
            SqlDataReader titleReader = titleCmd.ExecuteReader();

            if (!titleReader.Read())
            {
                titleReader.Close();
                Session[SESSION_QUESTIONS] = new List<QuizQuestion>();
                return;
            }

            string title = titleReader["quiz_title"].ToString();
            int courseId = Convert.ToInt32(titleReader["course_id"]);
            bool isPublished = Convert.ToBoolean(titleReader["published"]);
            titleReader.Close();

            bool isAdmin = Session["UserType"] != null && Session["UserType"].ToString() == "admin";

            if (!isAdmin)
            {
                if (!isPublished)
                {
                    Response.Redirect("CourseList.aspx");
                    return;
                }

                SqlCommand enrollCheck = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollment WHERE user_id=@uid AND course_id=@cid", conn);
                enrollCheck.Parameters.AddWithValue("@uid", int.Parse(Session["UserId"].ToString()));
                enrollCheck.Parameters.AddWithValue("@cid", courseId);

                if ((int)enrollCheck.ExecuteScalar() == 0)
                {
                    Response.Redirect("CourseList.aspx");
                    return;
                }
            }

            litQuizTitle.Text    = Server.HtmlEncode(title);
            litHeadingTitle.Text = Server.HtmlEncode(title);

            // Get all questions for this quiz
            SqlCommand cmd = new SqlCommand(
                @"SELECT question_id, question_text, option_a, option_b, option_c, option_d, correct_answer
                  FROM Questions WHERE quiz_id = @qid ORDER BY question_id", conn);
            cmd.Parameters.AddWithValue("@qid", quizId);

            SqlDataReader reader = cmd.ExecuteReader();
            var list = new List<QuizQuestion>();

            while (reader.Read())
            {
                list.Add(new QuizQuestion
                {
                    QuestionId    = (int)reader["question_id"],
                    QuestionText  = reader["question_text"].ToString(),
                    OptionA       = reader["option_a"].ToString(),
                    OptionB       = reader["option_b"].ToString(),
                    OptionC       = reader["option_c"].ToString(),
                    OptionD       = reader["option_d"].ToString(),
                    CorrectAnswer = reader["correct_answer"].ToString()
                });
            }

            Session[SESSION_QUESTIONS] = list;
        }
    }

    // Render the question at currentQ index
    private void DisplayCurrentQuestion()
    {
        if (questions == null || questions.Count == 0) return;

        var q = questions[currentQ];

        litQNum.Text      = (currentQ + 1).ToString();
        litQLabel.Text    = (currentQ + 1).ToString();
        litQTotal.Text    = questions.Count.ToString();
        litTotalQ.Text    = questions.Count.ToString();
        litQuestion.Text  = Server.HtmlEncode(q.QuestionText);

        // Calculate progress percentage
        int pct = (int)Math.Round(((currentQ + 1.0) / questions.Count) * 100);
        quizProgressFill.Style["width"] = pct + "%";

        // Build options list
        var options = new List<object>
        {
            new { key = "A", value = q.OptionA },
            new { key = "B", value = q.OptionB },
            new { key = "C", value = q.OptionC },
            new { key = "D", value = q.OptionD }
        };

        rptOptions.DataSource = options;
        rptOptions.DataBind();

        // Show/hide nav buttons appropriately
        btnPrevQ.Enabled      = currentQ > 0;
        btnNextQ.Visible      = currentQ < questions.Count - 1;
        btnSubmitQuiz.Visible = currentQ == questions.Count - 1;

        // Update flag button to show current flagged state
        bool isFlagged = flagged != null && flagged.Contains(currentQ);
        btnFlag.Text     = isFlagged ? "Flagged (Remove)" : "Flag for Review";
        btnFlag.CssClass = isFlagged ? "btn btn-warning btn-flag-active" : "btn btn-outline btn-flag";

        // Answered count
        litAnsweredCount.Text = answers.Count.ToString();

        // Build question navigator
        var navItems = new List<object>();
        for (int i = 0; i < questions.Count; i++)
            navItems.Add(new { index = i });

        rptQNav.DataSource = navItems;
        rptQNav.DataBind();
    }

    // Returns CSS class for question navigator button — can combine flagged with current/answered
    protected string GetNavBtnClass(int index)
    {
        string cls = "";
        if (index == currentQ) cls = "current";
        else if (answers != null && answers.ContainsKey(index)) cls = "answered";
        if (flagged != null && flagged.Contains(index)) cls += " flagged";
        return cls.Trim();
    }

    // Check if a given option key is the currently saved answer for this question
    protected bool IsSelected(string key)
    {
        if (answers == null) return false;
        return answers.ContainsKey(currentQ) && answers[currentQ] == key;
    }

    // Save the currently selected radio button answer
    private void SaveCurrentAnswer()
    {
        string selected = Request.Form["quizAnswer"];
        if (!string.IsNullOrEmpty(selected) && answers != null)
        {
            answers[currentQ] = selected;
            Session[SESSION_ANSWERS] = answers;
        }
    }

    protected void btnNextQ_Click(object sender, EventArgs e)
    {
        SaveCurrentAnswer();
        if (currentQ < questions.Count - 1)
        {
            currentQ++;
            hdnCurrentQ.Value = currentQ.ToString();
        }
        DisplayCurrentQuestion();
    }

    protected void btnPrevQ_Click(object sender, EventArgs e)
    {
        SaveCurrentAnswer();
        if (currentQ > 0)
        {
            currentQ--;
            hdnCurrentQ.Value = currentQ.ToString();
        }
        DisplayCurrentQuestion();
    }

    protected void btnFlag_Click(object sender, EventArgs e)
    {
        SaveCurrentAnswer();
        if (flagged.Contains(currentQ))
            flagged.Remove(currentQ);
        else
            flagged.Add(currentQ);
        Session[SESSION_FLAGGED] = flagged;
        DisplayCurrentQuestion();
    }

    protected void btnNavigate_Click(object sender, EventArgs e)
    {
        SaveCurrentAnswer();
        int target = -1;
        int.TryParse(hdnTargetQuestion.Value, out target);
        if (target >= 0 && target < questions.Count)
        {
            currentQ = target;
            hdnCurrentQ.Value = currentQ.ToString();
        }
        hdnTargetQuestion.Value = "-1";
        DisplayCurrentQuestion();
    }

    protected void btnSubmitQuiz_Click(object sender, EventArgs e)
    {
        SaveCurrentAnswer();

        int userId = int.Parse(Session["UserId"].ToString());
        int quizId = (int)Session[SESSION_QUIZ_ID];

        // Calculate score
        int correct = 0;
        foreach (var q in questions)
        {
            int index = questions.IndexOf(q);
            if (answers.ContainsKey(index) && answers[index] == q.CorrectAnswer)
                correct++;
        }

        int score = questions.Count > 0
            ? (int)Math.Round((correct * 100.0) / questions.Count)
            : 0;

        // Save attempt to database
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        int attemptId = 0;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Quiz_Attempts (user_id, quiz_id, score) OUTPUT INSERTED.attempt_id VALUES (@uid, @qid, @score)",
                conn);
            cmd.Parameters.AddWithValue("@uid",   userId);
            cmd.Parameters.AddWithValue("@qid",   quizId);
            cmd.Parameters.AddWithValue("@score", score);

            attemptId = (int)cmd.ExecuteScalar();

            // Save individual answers to Attempt_Answers table
            foreach (var q in questions)
            {
                int index = questions.IndexOf(q);
                string selectedAnswer = answers.ContainsKey(index) ? answers[index] : null;

                if (selectedAnswer != null)
                {
                    SqlCommand ansCmd = new SqlCommand(
                        "INSERT INTO Attempt_Answers (attempt_id, question_id, selected_answer) VALUES (@aid, @qid, @ans)",
                        conn);
                    ansCmd.Parameters.AddWithValue("@aid", attemptId);
                    ansCmd.Parameters.AddWithValue("@qid", q.QuestionId);
                    ansCmd.Parameters.AddWithValue("@ans", selectedAnswer);
                    ansCmd.ExecuteNonQuery();
                }
            }
        }

        // Store result in session for result page
        Session["QuizResult_Score"]     = score;
        Session["QuizResult_Correct"]   = correct;
        Session["QuizResult_Total"]     = questions.Count;
        Session["QuizResult_QuizTitle"] = litHeadingTitle.Text;
        Session["QuizResult_AttemptId"] = attemptId;

        // Clear quiz session data
        Session.Remove(SESSION_QUESTIONS);
        Session.Remove(SESSION_ANSWERS);
        Session.Remove(SESSION_FLAGGED);

        Response.Redirect("QuizResult.aspx");
    }
}
