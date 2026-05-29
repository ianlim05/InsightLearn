/*
 * Author:      Ng Ern Chi
 * Description: Student course listing page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CourseList : Page
{
    private const int PageSize = 6;  // number of courses shown per page
    public int CurrentPage { get; private set; }
    private int totalPages = 1;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) // only runs on first page load
        {
            CurrentPage = 1;
            ViewState["CurrentPage"] = 1; // save page number so postbacks can read it back
            LoadCourses();
        }
        else
        {
            CurrentPage = ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; // restore page number on postback
        }
    }

    private void LoadCourses()
    {
        string search   = txtSearch.Text.Trim();
        string category = ddlCategory.SelectedValue;
        string sort     = ddlSort.SelectedValue;
        int    userId   = Session["UserId"] != null ? int.Parse(Session["UserId"].ToString()) : 0; // 0 means guest (not logged in)

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            string whereClause = " WHERE c.published = 1 "; // only show courses the admin has published
            if (!string.IsNullOrEmpty(search))
                whereClause += " AND (c.course_name LIKE @search OR c.description LIKE @search OR c.category LIKE @search) ";
            if (!string.IsNullOrEmpty(category))
                whereClause += " AND c.category = @category ";

            // map dropdown value to ORDER BY clause
            string orderClause = sort == "name_desc" ? " ORDER BY c.course_name DESC " :
                                 sort == "newest"    ? " ORDER BY c.course_id DESC " :
                                                       " ORDER BY c.course_name ASC ";

            // first query: count total matching rows to calculate total pages
            string countSql = "SELECT COUNT(*) FROM Courses c" + whereClause;
            SqlCommand countCmd = new SqlCommand(countSql, conn);
            if (!string.IsNullOrEmpty(search))   countCmd.Parameters.AddWithValue("@search",   "%" + search + "%");
            if (!string.IsNullOrEmpty(category)) countCmd.Parameters.AddWithValue("@category", category);

            int totalRecords = (int)countCmd.ExecuteScalar();
            totalPages = Math.Max(1, (int)Math.Ceiling((double)totalRecords / PageSize)); // ceiling division e.g. 13 ÷ 6 = 3 pages

            if (CurrentPage > totalPages) CurrentPage = totalPages; // clamp page if filters reduce results

            int offset = (CurrentPage - 1) * PageSize; // how many rows to skip

            // second query: fetch only the current page's rows using OFFSET/FETCH
            string sql = @"
                SELECT
                    c.course_id,
                    c.course_name,
                    c.description,
                    c.category,
                    (SELECT COUNT(*) FROM Lessons l WHERE l.course_id = c.course_id) AS lesson_count,
                    (SELECT COUNT(*) FROM Quizzes q WHERE q.course_id = c.course_id) AS quiz_count,
                    CASE WHEN e.enrollment_id IS NOT NULL THEN 1 ELSE 0 END AS is_enrolled -- 1 if student is enrolled, 0 if not
                FROM Courses c
                LEFT JOIN Enrollment e ON c.course_id = e.course_id AND e.user_id = @userId -- LEFT JOIN keeps all courses even if not enrolled
                " + whereClause + orderClause +
                " OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY"; // returns only the current page rows

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@userId",   userId);
            cmd.Parameters.AddWithValue("@offset",   offset);
            cmd.Parameters.AddWithValue("@pageSize", PageSize);
            if (!string.IsNullOrEmpty(search))   cmd.Parameters.AddWithValue("@search",   "%" + search + "%");
            if (!string.IsNullOrEmpty(category)) cmd.Parameters.AddWithValue("@category", category);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                rptCourses.Visible   = true;
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                pnlNoResults.Visible = false;
            }
            else
            {
                rptCourses.Visible   = false;
                pnlNoResults.Visible = true; // show "no courses found" message
            }

            BuildPagination(totalPages);
        }
    }

    // builds the row of numbered page buttons; hides pagination if only one page
    private void BuildPagination(int total)
    {
        if (total <= 1)
        {
            pnlPagination.Visible = false;
            return;
        }

        pnlPagination.Visible = true;
        btnPrev.Enabled = CurrentPage > 1;     // disable Prev on first page
        btnNext.Enabled = CurrentPage < total; // disable Next on last page

        var pages = new System.Collections.Generic.List<object>();
        for (int i = 1; i <= total; i++)
            pages.Add(new { PageNum = i }); // anonymous object so Eval("PageNum") works in the Repeater

        rptPages.DataSource = pages;
        rptPages.DataBind();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        CurrentPage = 1;
        ViewState["CurrentPage"] = 1; // reset to page 1 on new search
        LoadCourses();
    }

    protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        CurrentPage = 1;
        ViewState["CurrentPage"] = 1; // reset to page 1 when filter changes
        LoadCourses();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses(); // keep current page, just re-order
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        if (CurrentPage > 1)
        {
            CurrentPage--;
            ViewState["CurrentPage"] = CurrentPage;
            LoadCourses();
        }
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        CurrentPage++;
        ViewState["CurrentPage"] = CurrentPage;
        LoadCourses();
    }

    protected void lbPage_Command(object sender, CommandEventArgs e)
    {
        CurrentPage = int.Parse(e.CommandArgument.ToString()); // jump to the page number that was clicked
        ViewState["CurrentPage"] = CurrentPage;
        LoadCourses();
    }

    protected void btnEnroll_Click(object sender, EventArgs e)
    {
        if (Session["UserId"] == null) // not logged in — redirect to login
        {
            Response.Redirect("Login.aspx");
            return;
        }

        int courseId = 0;
        if (!int.TryParse(hdnEnrollCourseId.Value, out courseId)) return;

        int userId = int.Parse(Session["UserId"].ToString());

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // check the course is still published before enrolling
            SqlCommand publishCheckCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Courses WHERE course_id=@cid AND published=1", conn);
            publishCheckCmd.Parameters.AddWithValue("@cid", courseId);

            if ((int)publishCheckCmd.ExecuteScalar() == 0)
            {
                ShowMessage("This course is not available for enrollment yet.", false);
                return;
            }

            // check if already enrolled — avoid inserting a duplicate row
            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Enrollment WHERE user_id=@uid AND course_id=@cid", conn);
            checkCmd.Parameters.AddWithValue("@uid", userId);
            checkCmd.Parameters.AddWithValue("@cid", courseId);

            if ((int)checkCmd.ExecuteScalar() > 0)
            {
                Response.Redirect("Lesson.aspx?courseId=" + courseId); // already enrolled, go straight to lesson
                return;
            }

            // insert new enrollment record
            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Enrollment (user_id, course_id) VALUES (@uid, @cid)", conn);
            cmd.Parameters.AddWithValue("@uid", userId);
            cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.ExecuteNonQuery();
        }

        Response.Redirect("Lesson.aspx?courseId=" + courseId); // go to first lesson after enrolling
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible = true;
    }

    // returns different button HTML depending on whether the student is logged in / enrolled
    protected string GetActionButton(object courseId, object isEnrolled)
    {
        int cid = Convert.ToInt32(courseId);

        if (Session["UserId"] == null)
        {
            // not logged in — clicking Enroll sends to login page
            return string.Format(
                "<a href=\"Login.aspx\" class=\"btn btn-outline btn-sm btn-block\">Enroll Now</a>");
        }

        bool enrolled = Convert.ToInt32(isEnrolled) == 1;

        if (enrolled)
        {
            // already enrolled — show Continue Learning
            return string.Format(
                "<a href=\"Lesson.aspx?courseId={0}\" class=\"btn btn-primary btn-sm btn-block\">Continue Learning</a>", cid);
        }
        else
        {
            // not enrolled — clicking sets the hidden field then triggers btnEnroll via JavaScript
            return string.Format(
                "<a href=\"CourseList.aspx?enroll={0}\" class=\"btn btn-outline btn-sm btn-block\" " +
                "onclick=\"document.getElementById('{1}').value='{0}'; document.getElementById('{2}').click(); return false;\">Enroll Now</a>",
                cid,
                hdnEnrollCourseId.ClientID,
                btnEnroll.ClientID);
        }
    }

    // these three helpers return CSS class names based on category for card colours
    protected string GetThumbClass(string cat)
    {
        switch (cat.ToLower())
        {
            case "programming":      return "thumb-programming";
            case "web development":  return "thumb-webdev";
            case "computer science": return "thumb-cs";
            case "mathematics":      return "thumb-math";
            case "data science":     return "thumb-datascience";
            case "design":           return "thumb-design";
            default:                 return "thumb-default";
        }
    }

    protected string GetTagClass(string cat)
    {
        switch (cat.ToLower())
        {
            case "programming":      return "tag-programming";
            case "web development":  return "tag-webdev";
            case "computer science": return "tag-cs";
            case "mathematics":      return "tag-math";
            case "data science":     return "tag-datascience";
            case "design":           return "tag-design";
            default:                 return "tag-default";
        }
    }

    protected string GetCatIcon(string cat) // returns a Unicode emoji for the category thumbnail
    {
        switch (cat.ToLower())
        {
            case "programming":      return "&#128187;";
            case "web development":  return "&#127760;";
            case "computer science": return "&#128296;";
            case "mathematics":      return "&#8734;";
            case "data science":     return "&#128202;";
            case "design":           return "&#127912;";
            default:                 return "&#128214;";
        }
    }
}
