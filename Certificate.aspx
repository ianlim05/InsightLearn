<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Certificate.aspx.cs" Inherits="Certificate"
    MasterPageFile="~/Site.master" Title="My Certificates" %>
<%--
    Author:      Foo Kim Chean
    Description: Course completion certificate page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">My Certificates</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="cert-page">
  <div class="container">

    <!-- Page Header -->
    <div class="page-header">
        <h1>&#127941; My Certificates</h1>
        <p>Courses you have fully completed. Well done!</p>
    </div>

    <!-- Breadcrumb -->
    <div class="breadcrumb" style="margin-bottom:24px;">
        <a href="Default.aspx">Home</a>
        <span class="sep">&#8250;</span>
        <a href="StudentDashboard.aspx">Dashboard</a>
        <span class="sep">&#8250;</span>
        <span class="current">Certificates</span>
    </div>

    <!-- No certificates message -->
    <asp:Panel ID="pnlNoCerts" runat="server" Visible="false">
        <div class="empty-state">
            <div class="empty-icon">&#127941;</div>
            <h3>No certificates yet</h3>
            <p>Complete all lessons in a course to earn your certificate.</p>
            <a href="CourseList.aspx" class="btn btn-primary" style="margin-top:12px;">Browse Courses</a>
        </div>
    </asp:Panel>

    <!-- Certificates Grid -->
    <asp:Panel ID="pnlCerts" runat="server">
        <div class="cert-grid">
            <asp:Repeater ID="rptCerts" runat="server">
                <ItemTemplate>
                    <div class="cert-card">
                        <div class="cert-ribbon">COMPLETED</div>
                        <div class="cert-icon">&#127941;</div>
                        <div class="cert-body">
                            <div class="cert-label">Certificate of Completion</div>
                            <div class="cert-course-name"><%# Server.HtmlEncode(Eval("course_name").ToString()) %></div>
                            <div class="cert-category">
                                <span class="course-tag"><%# Server.HtmlEncode(Eval("category").ToString()) %></span>
                            </div>
                            <div class="cert-meta">
                                <div class="cert-meta-row">
                                    <span class="cert-meta-icon">&#128100;</span>
                                    <span><asp:Label ID="lblStudentName" runat="server" /></span>
                                </div>
                                <div class="cert-meta-row">
                                    <span class="cert-meta-icon">&#128197;</span>
                                    <span>Completed: <%# Eval("completion_date") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("completion_date")).ToString("MMMM dd, yyyy")
                                        : "N/A" %></span>
                                </div>
                                <div class="cert-meta-row">
                                    <span class="cert-meta-icon">&#128218;</span>
                                    <span><%# Eval("lesson_count") %> Lessons</span>
                                </div>
                            </div>
                        </div>
                        <div class="cert-footer">
                            <span class="cert-verified">&#10003; Verified by InsightLearn</span>
                            <a href='Lesson.aspx?courseId=<%# Eval("course_id") %>'
                               class="btn btn-outline btn-sm">Review Course</a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

  </div>
</div>

</asp:Content>
