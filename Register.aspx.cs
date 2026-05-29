/*
 * Author:      Ian Lim
 * Description: User registration page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

public partial class Register : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Already logged in? Redirect away
        if (!IsPostBack && Session["UserId"] != null)
        {
            Response.Redirect("StudentDashboard.aspx");
        }
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        // Read form values
        string name     = txtName.Text.Trim();
        string email    = txtEmail.Text.Trim().ToLower();
        string password = txtPassword.Text;
        string confirm  = txtConfirmPassword.Text;

        // Extra server-side validation
        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
        {
            ShowMessage("Please fill in all fields.", false);
            return;
        }

        if (password != confirm)
        {
            ShowMessage("Passwords do not match.", false);
            return;
        }

        if (password.Length < 6)
        {
            ShowMessage("Password must be at least 6 characters.", false);
            return;
        }

        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            try
            {
                conn.Open();

                // Check if email already exists
                string checkSql = "SELECT COUNT(*) FROM Users WHERE email = @email";
                SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@email", email);

                int existingCount = (int)checkCmd.ExecuteScalar();

                if (existingCount > 0)
                {
                    ShowMessage("This email address is already registered. Please login instead.", false);
                    return;
                }

                // Insert new user with 'student' role by default
                string insertSql = "INSERT INTO Users (name, email, password, role) VALUES (@name, @email, @password, 'student')";

                SqlCommand cmd = new SqlCommand(insertSql, conn);
                cmd.Parameters.AddWithValue("@name",     name);
                cmd.Parameters.AddWithValue("@email",    email);
                cmd.Parameters.AddWithValue("@password", password);

                int rows = cmd.ExecuteNonQuery();

                if (rows > 0)
                {
                    // Registration successful — redirect to login
                    ShowMessage("Account created successfully! You can now login.", true);
                    // Clear form fields
                    txtName.Text = txtEmail.Text = string.Empty;
                }
                else
                {
                    ShowMessage("Registration failed. Please try again.", false);
                }
            }
            catch (Exception)
            {
                ShowMessage("A database error occurred. Please try again.", false);
            }
        }
    }

    // Helper to show styled message
    private void ShowMessage(string message, bool isSuccess)
    {
        lblMessage.Text = message;
        lblMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";
        lblMessage.Visible = true;
    }
}
