/*
 * Author:      Ian Lim
 * Description: Student-facing master page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Web.UI;

public partial class Site : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Check if user is logged in and update nav accordingly
        if (Session["UserId"] != null)
        {
            // Show logout button and user name, hide login button
            hlLogin.Visible = false;
            lbLogout.Visible = true;
            hlNavUser.Visible = true;
            hlNavUser.Text = "Hi, " + Session["UserName"].ToString();

            // Show Dashboard link only for students
            if (Session["UserType"] != null && Session["UserType"].ToString() == "student")
            {
                navDashboard.Visible = true;
            }
        }
        else
        {
            hlLogin.Visible = true;
            lbLogout.Visible = false;
            hlNavUser.Visible = false;
            navDashboard.Visible = false;
        }

        // Highlight active nav link based on current page
        string currentPage = System.IO.Path.GetFileName(Request.Path).ToLower();

        switch (currentPage)
        {
            case "default.aspx":
            case "":
                navHome.Attributes["class"] = "active";
                break;
            case "courselist.aspx":
                navCourses.Attributes["class"] = "active";
                break;
            case "studentdashboard.aspx":
                if (navDashboard.Visible)
                    navDashboard.CssClass = "active";
                break;
            case "about.aspx":
                navAbout.Attributes["class"] = "active";
                break;
        }
    }

    protected void lbLogout_Click(object sender, EventArgs e)
    {
        // Clear all session data and redirect to login
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}
