/*
 * Author:      Ian Lim
 * Description: Account settings page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

public partial class Settings : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Must be logged in
        if (Session["UserId"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadUserInfo();
        }
        else
        {
            // On postback, refresh the header avatar/name from session (may have been updated)
            RefreshHeader();
        }
    }

    // Load current user data from the database and populate fields
    private void LoadUserInfo()
    {
        int userId = int.Parse(Session["UserId"].ToString());
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "SELECT name, email FROM Users WHERE user_id = @uid", conn);
            cmd.Parameters.AddWithValue("@uid", userId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                string name  = reader["name"].ToString();
                string email = reader["email"].ToString();

                txtDisplayName.Text = name;
                txtEmail.Text       = email;

                // Set header
                litHeaderName.Text  = Server.HtmlEncode(name);
                litHeaderEmail.Text = Server.HtmlEncode(email);
                litAvatarInitial.Text = name.Length > 0
                    ? Server.HtmlEncode(name.Substring(0, 1).ToUpper())
                    : "?";
            }
        }
    }

    // Refresh the hero header section using current session name
    private void RefreshHeader()
    {
        string name = Session["UserName"] != null ? Session["UserName"].ToString() : "";
        litHeaderName.Text    = Server.HtmlEncode(name);
        litAvatarInitial.Text = name.Length > 0
            ? Server.HtmlEncode(name.Substring(0, 1).ToUpper())
            : "?";

        // Email is set from the TextBox (which has ViewState, so it persists)
        litHeaderEmail.Text = Server.HtmlEncode(txtEmail.Text);
    }

    // ---- Save Display Name ----

    protected void btnSaveName_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string newName = txtDisplayName.Text.Trim();

        if (string.IsNullOrEmpty(newName))
        {
            ShowProfileMessage("&#9888; Display name cannot be empty.", false);
            return;
        }

        int userId = int.Parse(Session["UserId"].ToString());
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand(
                "UPDATE Users SET name = @name WHERE user_id = @uid", conn);
            cmd.Parameters.AddWithValue("@name", newName);
            cmd.Parameters.AddWithValue("@uid",  userId);
            cmd.ExecuteNonQuery();
        }

        // Update session so nav bar reflects the new name immediately
        Session["UserName"] = newName;

        litHeaderName.Text    = Server.HtmlEncode(newName);
        litAvatarInitial.Text = Server.HtmlEncode(newName.Substring(0, 1).ToUpper());

        ShowProfileMessage("&#10003; Display name updated successfully!", true);
    }

    // ---- Change Password ----

    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string currentPw  = txtCurrentPassword.Text;
        string newPw       = txtNewPassword.Text;
        string confirmPw   = txtConfirmPassword.Text;

        if (newPw != confirmPw)
        {
            ShowPasswordMessage("&#9888; New passwords do not match.", false);
            return;
        }

        if (newPw.Length < 6)
        {
            ShowPasswordMessage("&#9888; New password must be at least 6 characters.", false);
            return;
        }

        int userId = int.Parse(Session["UserId"].ToString());
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // Verify current password
            SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM Users WHERE user_id = @uid AND password = @pw", conn);
            checkCmd.Parameters.AddWithValue("@uid", userId);
            checkCmd.Parameters.AddWithValue("@pw",  currentPw);
            int count = (int)checkCmd.ExecuteScalar();

            if (count == 0)
            {
                ShowPasswordMessage("&#9888; Current password is incorrect.", false);
                return;
            }

            // Update to new password
            SqlCommand updateCmd = new SqlCommand(
                "UPDATE Users SET password = @newpw WHERE user_id = @uid", conn);
            updateCmd.Parameters.AddWithValue("@newpw", newPw);
            updateCmd.Parameters.AddWithValue("@uid",   userId);
            updateCmd.ExecuteNonQuery();
        }

        // Clear password fields on success
        txtCurrentPassword.Text = "";
        txtNewPassword.Text     = "";
        txtConfirmPassword.Text = "";

        ShowPasswordMessage("&#10003; Password changed successfully!", true);
    }

    // ---- Helpers ----

    private void ShowProfileMessage(string msg, bool success)
    {
        lblProfileMsg.Text     = msg;
        lblProfileMsg.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblProfileMsg.Visible  = true;
    }

    private void ShowPasswordMessage(string msg, bool success)
    {
        lblPasswordMsg.Text     = msg;
        lblPasswordMsg.CssClass = success ? "alert alert-success" : "alert alert-danger";
        lblPasswordMsg.Visible  = true;
    }
}
