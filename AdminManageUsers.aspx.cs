/*
 * Author:      Ian Lim
 * Description: User management page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminManageUsers : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadUsers();
        }
    }

    private void LoadUsers()
    {
        string search     = txtSearch.Text.Trim();
        string roleFilter = ddlRoleFilter.SelectedValue;
        string connStr    = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            string sql = @"
                SELECT u.user_id, u.name, u.email, u.role,
                    (SELECT COUNT(*) FROM Enrollment e WHERE e.user_id = u.user_id) AS enrolled_courses
                FROM Users u
                WHERE 1=1 ";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (u.name LIKE @search OR u.email LIKE @search) ";
            if (!string.IsNullOrEmpty(roleFilter))
                sql += " AND u.role = @role ";

            sql += " ORDER BY u.user_id";

            SqlCommand cmd = new SqlCommand(sql, conn);

            if (!string.IsNullOrEmpty(search))
                cmd.Parameters.AddWithValue("@search", "%" + search + "%");
            if (!string.IsNullOrEmpty(roleFilter))
                cmd.Parameters.AddWithValue("@role", roleFilter);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvUsers.DataSource = dt;
            gvUsers.DataBind();
        }

        LoadSummaryStats();
    }

    private void LoadSummaryStats()
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users", conn);
            litCountTotal.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE role = 'student'", conn);
            litCountStudents.Text = cmd.ExecuteScalar().ToString();

            cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE role = 'admin'", conn);
            litCountAdmins.Text = cmd.ExecuteScalar().ToString();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvUsers.PageIndex = 0;
        LoadUsers();
    }

    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlRoleFilter.SelectedIndex = 0;
        gvUsers.PageIndex = 0;
        LoadUsers();
    }

    protected void ddlRoleFilter_Changed(object sender, EventArgs e)
    {
        gvUsers.PageIndex = 0;
        LoadUsers();
    }

    protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvUsers.PageIndex = e.NewPageIndex;
        LoadUsers();
    }

    protected void btnShowAdd_Click(object sender, EventArgs e)
    {
        pnlAddUser.Visible  = true;
        pnlEditUser.Visible = false;
        txtAddName.Text     = "";
        txtAddEmail.Text    = "";
    }

    protected void btnCancelAdd_Click(object sender, EventArgs e)
    {
        pnlAddUser.Visible = false;
    }

    protected void btnAddUser_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string name     = txtAddName.Text.Trim();
        string email    = txtAddEmail.Text.Trim();
        string password = txtAddPassword.Text;
        string role     = ddlAddRole.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Check for duplicate email
            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Users WHERE email = @email", conn);
            checkCmd.Parameters.AddWithValue("@email", email);

            if ((int)checkCmd.ExecuteScalar() > 0)
            {
                ShowMessage("&#9888; That email address is already in use.", false);
                return;
            }

            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Users (name, email, password, role) VALUES (@name, @email, @pwd, @role)", conn);
            cmd.Parameters.AddWithValue("@name",  name);
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@pwd",   password);
            cmd.Parameters.AddWithValue("@role",  role);
            cmd.ExecuteNonQuery();
        }

        pnlAddUser.Visible = false;
        ShowMessage("&#10003; User added successfully!", true);
        LoadUsers();
    }

    protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int targetUserId = int.Parse(e.CommandArgument.ToString());

        if (e.CommandName == "EditUser")
        {
            LoadUserForEdit(targetUserId);
        }
        else if (e.CommandName == "DeleteUser")
        {
            // Prevent admin from deleting their own account
            int currentUserId = int.Parse(Session["UserId"].ToString());
            if (targetUserId == currentUserId)
            {
                ShowMessage("&#9888; You cannot delete your own account.", false);
                return;
            }
            DeleteUser(targetUserId);
        }
    }

    private void LoadUserForEdit(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT user_id, name, email, role FROM Users WHERE user_id = @uid", conn);
            cmd.Parameters.AddWithValue("@uid", userId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                hdnEditUserId.Value       = reader["user_id"].ToString();
                txtEditName.Text          = reader["name"].ToString();
                txtEditEmail.Text         = reader["email"].ToString();
                ddlEditRole.SelectedValue = reader["role"].ToString();
            }
        }

        pnlEditUser.Visible = true;
        pnlAddUser.Visible  = false;
    }

    protected void btnSaveEdit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int userId   = int.Parse(hdnEditUserId.Value);
        string name  = txtEditName.Text.Trim();
        string email = txtEditEmail.Text.Trim();
        string role  = ddlEditRole.SelectedValue;

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Check duplicate email (excluding current user)
            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Users WHERE email = @email AND user_id <> @uid", conn);
            checkCmd.Parameters.AddWithValue("@email", email);
            checkCmd.Parameters.AddWithValue("@uid",   userId);

            if ((int)checkCmd.ExecuteScalar() > 0)
            {
                ShowMessage("&#9888; That email address is already used by another account.", false);
                return;
            }

            SqlCommand cmd = new SqlCommand(
                "UPDATE Users SET name=@name, email=@email, role=@role WHERE user_id=@uid", conn);
            cmd.Parameters.AddWithValue("@name",  name);
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@role",  role);
            cmd.Parameters.AddWithValue("@uid",   userId);
            cmd.ExecuteNonQuery();
        }

        pnlEditUser.Visible = false;
        ShowMessage("&#10003; User updated successfully!", true);
        LoadUsers();
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        pnlEditUser.Visible = false;
    }

    private void DeleteUser(int userId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            // FK cascade handles related records
            SqlCommand cmd = new SqlCommand(
                "DELETE FROM Users WHERE user_id = @uid", conn);
            cmd.Parameters.AddWithValue("@uid", userId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("&#10003; User deleted successfully.", true);
        LoadUsers();
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text    = msg;
        lblMessage.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible  = true;
    }
}
