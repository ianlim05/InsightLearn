/*
 * Author:      Ian Lim
 * Description: Login page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

public partial class Login : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // If already logged in, redirect to appropriate dashboard
        if (!IsPostBack && Session["UserId"] != null)
        {
            RedirectByRole(Session["UserType"].ToString());
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        // Server-side validation (in addition to ASP.NET validators)
        string email = txtEmail.Text.Trim();
        string password = txtPassword.Text;

        if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
        {
            ShowError("Please fill in all fields.");
            return;
        }

        // Look up user in database using parameterized query
        string connStr = ConfigurationManager.ConnectionStrings["InsightLearnDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            try
            {
                conn.Open();

                // NOTE: In production, passwords should be hashed (e.g. SHA256)
                // For this demo, plain text comparison is used
                string sql = "SELECT user_id, name, role FROM Users WHERE email = @email AND password = @password";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@password", password);

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    // Valid credentials — set session variables
                    Session["UserId"]   = reader["user_id"].ToString();
                    Session["UserName"] = reader["name"].ToString();
                    Session["UserType"] = reader["role"].ToString();

                    reader.Close();

                    // Redirect based on user role
                    RedirectByRole(Session["UserType"].ToString());
                }
                else
                {
                    reader.Close();
                    ShowError("Invalid email or password. Please try again.");
                }
            }
            catch (Exception)
            {
                ShowError("A database error occurred. Please try again later.");
            }
        }
    }

    // Show inline error message
    private void ShowError(string message)
    {
        lblError.Text = "&#9888; " + message;
        lblError.Visible = true;
    }

    // Redirect user to correct dashboard based on their role
    private void RedirectByRole(string role)
    {
        if (role == "admin")
            Response.Redirect("AdminDashboard.aspx");
        else
            Response.Redirect("StudentDashboard.aspx");
    }

}
