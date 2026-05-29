/*
 * Author:      Ian Lim
 * Description: Admin master page (code-behind)
 * Date:        23/5/2026
 */
using System;
using System.Web.UI;

public partial class AdminSite : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Protect all admin pages — redirect non-admins immediately
        if (Session["UserType"] == null || Session["UserType"].ToString() != "admin")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        // Show admin user name
        lblAdminName.Text = "&#128100; " + Server.HtmlEncode(Session["UserName"].ToString());

        // Highlight active admin nav link
        string currentPage = System.IO.Path.GetFileName(Request.Path).ToLower();

        switch (currentPage)
        {
            case "admindashboard.aspx":
                navAdminDash.Attributes["class"] = "active";
                break;
            case "adminmanageusers.aspx":
                navAdminUsers.Attributes["class"] = "active";
                break;
            case "adminmanagecourses.aspx":
                navAdminCourses.Attributes["class"] = "active";
                break;
            case "adminmanagelessons.aspx":
                navAdminLessons.Attributes["class"] = "active";
                break;
            case "adminmanagequizzes.aspx":
                navAdminQuizzes.Attributes["class"] = "active";
                break;
        }
    }

    protected void lbExitAdmin_Click(object sender, EventArgs e)
    {
        // Log out admin and go back to home
        Session.Abandon();
        Response.Redirect("Default.aspx");
    }
}
