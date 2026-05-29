/*
 * Author:      Ng Ern Chi
 * Description: Course management page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminManageCourses : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) // only runs on first page load, not on button clicks
        {
            LoadCourses();
        }
    }

    private void LoadCourses()
    {
        string search   = txtSearch.Text.Trim();
        string category = ddlCategoryFilter.SelectedValue;
        string connStr  = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString; // reads DB connection string from Web.config

        using (SqlConnection conn = new SqlConnection(connStr)) // opens the database connection
        {
            conn.Open();

            string sql = @"
                SELECT
                    c.course_id,
                    c.course_name,
                    c.category,
                    (SELECT COUNT(*) FROM Lessons  l WHERE l.course_id = c.course_id) AS lesson_count,  -- counts lessons for each course
                    (SELECT COUNT(*) FROM Quizzes  q WHERE q.course_id = c.course_id) AS quiz_count,    -- counts quizzes for each course
                    (SELECT COUNT(*) FROM Enrollment e WHERE e.course_id = c.course_id) AS enrolled     -- counts enrolled students
                FROM Courses c
                WHERE 1=1 "; // WHERE 1=1 lets us safely add optional AND filters below

            if (!string.IsNullOrEmpty(search))
                sql += " AND (c.course_name LIKE @search OR c.description LIKE @search) ";
            if (!string.IsNullOrEmpty(category))
                sql += " AND c.category = @category ";

            sql += " ORDER BY c.course_id";

            SqlCommand cmd = new SqlCommand(sql, conn);

            // @search and @category are parameters — prevents SQL injection
            if (!string.IsNullOrEmpty(search))
                cmd.Parameters.AddWithValue("@search", "%" + search + "%");
            if (!string.IsNullOrEmpty(category))
                cmd.Parameters.AddWithValue("@category", category);

            SqlDataAdapter da = new SqlDataAdapter(cmd); // fills a DataTable from the query result
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCourses.DataSource = dt; // give the data to the GridView
            gvCourses.DataBind();      // tells GridView to render the rows
        }

        LoadSummaryStats();
    }

    // updates the 3 stat chips (total courses / lessons / enrollments) at the top
    private void LoadSummaryStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Courses", conn);
            litCountCourses.Text = cmd.ExecuteScalar().ToString(); // ExecuteScalar returns a single value

            cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons", conn);
            litCountLessons.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Enrollment", conn);
            litCountEnrolled.Text = cmd.ExecuteScalar().ToString();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvCourses.PageIndex = 0; // reset to first page before searching
        LoadCourses();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlCategoryFilter.SelectedIndex = 0; // reset dropdown to "All Categories"
        gvCourses.PageIndex = 0;
        LoadCourses();
    }

    protected void ddlCategoryFilter_Changed(object sender, EventArgs e)
    {
        gvCourses.PageIndex = 0;
        LoadCourses();
    }

    protected void gvCourses_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvCourses.PageIndex = e.NewPageIndex; // move to the page the user clicked
        LoadCourses();
    }

    protected void btnShowAdd_Click(object sender, EventArgs e)
    {
        pnlAddCourse.Visible  = true;  // show the Add form
        pnlEditCourse.Visible = false; // hide the Edit form
        txtAddName.Text        = "";
        txtAddDescription.Text = "";
        ddlAddCategory.SelectedIndex = 0;
    }

    protected void btnCancelAdd_Click(object sender, EventArgs e)
    {
        pnlAddCourse.Visible = false; // hide the Add form
    }

    protected void btnAddCourse_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return; // stop if any validator failed

        string name     = txtAddName.Text.Trim();
        string desc     = txtAddDescription.Text.Trim();
        string category = ddlAddCategory.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Courses (course_name, description, category) VALUES (@name, @desc, @cat)", conn);
            cmd.Parameters.AddWithValue("@name", name);
            cmd.Parameters.AddWithValue("@desc", desc);
            cmd.Parameters.AddWithValue("@cat",  category);
            cmd.ExecuteNonQuery(); // runs the INSERT, returns no data
        }

        pnlAddCourse.Visible = false;
        ShowMessage("&#10003; Course added successfully!", true);
        LoadCourses(); // refresh the grid to show the new course
    }

    // fires when any button inside a GridView row is clicked
    protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        // ignore built-in pager commands (CommandArgument would be "Prev"/"Next", not a course_id)
        if (e.CommandName != "EditCourse" && e.CommandName != "DeleteCourse") return;

        int courseId = int.Parse(e.CommandArgument.ToString()); // course_id from the clicked row

        if (e.CommandName == "EditCourse")
        {
            LoadCourseForEdit(courseId);
        }
        else if (e.CommandName == "DeleteCourse")
        {
            DeleteCourse(courseId);
        }
    }

    // loads the selected course into the Edit form fields
    private void LoadCourseForEdit(int courseId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT course_id, course_name, description, category FROM Courses WHERE course_id = @cid", conn);
            cmd.Parameters.AddWithValue("@cid", courseId);
            SqlDataReader reader = cmd.ExecuteReader(); // reads rows one by one

            if (reader.Read())
            {
                hdnEditCourseId.Value    = reader["course_id"].ToString();   // save ID for the Save button
                txtEditName.Text         = reader["course_name"].ToString();
                txtEditDescription.Text  = reader["description"].ToString();
                ddlEditCategory.SelectedValue = reader["category"].ToString();
            }
        }

        pnlEditCourse.Visible = true;  // show the Edit form
        pnlAddCourse.Visible  = false;
    }

    protected void btnSaveEdit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int courseId    = int.Parse(hdnEditCourseId.Value); // get the ID saved when Edit was opened
        string name     = txtEditName.Text.Trim();
        string desc     = txtEditDescription.Text.Trim();
        string category = ddlEditCategory.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "UPDATE Courses SET course_name=@name, description=@desc, category=@cat WHERE course_id=@cid", conn);
            cmd.Parameters.AddWithValue("@name", name);
            cmd.Parameters.AddWithValue("@desc", desc);
            cmd.Parameters.AddWithValue("@cat",  category);
            cmd.Parameters.AddWithValue("@cid",  courseId);
            cmd.ExecuteNonQuery();
        }

        pnlEditCourse.Visible = false;
        ShowMessage("&#10003; Course updated successfully!", true);
        LoadCourses();
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        pnlEditCourse.Visible = false; // hide the Edit form
    }

    private void DeleteCourse(int courseId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            // FK cascade in the database removes lessons, quizzes, and enrollments automatically
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Courses WHERE course_id = @cid", conn);
            cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("&#10003; Course deleted successfully.", true);
        LoadCourses();
    }

    // returns a CSS class name based on category, used for the coloured tag badge
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

    // sets the label text, colour (green/red), and makes it visible
    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text     = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible  = true;
    }
}
