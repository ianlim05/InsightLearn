<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="AdminDashboard"
    MasterPageFile="~/AdminSite.master" Title="Admin Dashboard" %>
<%--
    Author:      Oswald Loh Kar Tzun
    Description: Admin analytics dashboard (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Admin Dashboard</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="admin-page">
  <div class="container">

    <!-- Page Header -->
    <div class="admin-page-header">
        <h1>Dashboard Overview</h1>
        <p>Welcome back, <strong><asp:Literal ID="litAdminName" runat="server">Admin</asp:Literal></strong>. Here is a summary of platform activity.</p>
    </div>

    <!-- ===== STATS CARDS (4 only, as per wireframe) ===== -->
    <div class="stats-grid" style="grid-template-columns: repeat(4,1fr);">

        <div class="stat-card">
            <div class="stat-icon" style="background:#EDE9FE; color:#6D28D9; font-size:1.4rem;">&#128101;</div>
            <div class="stat-info">
                <div class="stat-num"><asp:Literal ID="litTotalStudents" runat="server">0</asp:Literal></div>
                <div class="stat-label">Total Students</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background:#D1FAE5; color:#065F46; font-size:1.4rem;">&#128218;</div>
            <div class="stat-info">
                <div class="stat-num"><asp:Literal ID="litTotalCourses" runat="server">0</asp:Literal></div>
                <div class="stat-label">Active Courses</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background:#FEF3C7; color:#92400E; font-size:1.4rem;">&#128203;</div>
            <div class="stat-info">
                <div class="stat-num"><asp:Literal ID="litTotalQuizzes" runat="server">0</asp:Literal></div>
                <div class="stat-label">Total Quizzes</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background:#EDE9FE; color:#5B21B6; font-size:1.4rem;">&#128200;</div>
            <div class="stat-info">
                <div class="stat-num"><asp:Literal ID="litEnrollments" runat="server">0</asp:Literal></div>
                <div class="stat-label">Total Enrollments</div>
            </div>
        </div>

    </div>

    <!-- ===== MAIN GRID: Enrollment Trend + Quick Actions ===== -->
    <div class="dashboard-grid" style="grid-template-columns: 1fr 300px; margin-top:8px;">

      <!-- LEFT: Enrollment Trend Chart -->
      <div>

          <!-- Enrollment Trend -->
          <div class="card" style="margin-bottom:24px;">
              <div class="card-header">
                  <h3>&#128200; Student Enrollment Trend</h3>
                  <span style="font-size:0.8rem; color:var(--text-light);">Last 6 months</span>
              </div>
              <div class="card-body">
                  <p style="font-size:0.82rem; color:var(--text-light); margin-bottom:14px;">
                      Monthly new student enrollments
                  </p>
                  <div id="enrollmentTrendChart" style="width:100%; min-height:200px;"></div>
              </div>
          </div>

          <!-- Recent Enrollments -->
          <div class="card">
              <div class="card-header">
                  <h3>Recent Enrollments</h3>
                  <a href="AdminManageUsers.aspx" class="btn btn-outline btn-sm">View All</a>
              </div>
              <div class="card-body" style="padding:0;">
                  <asp:Repeater ID="rptRecentEnrollments" runat="server">
                      <HeaderTemplate>
                          <table class="data-table" style="width:100%;">
                              <thead>
                                  <tr>
                                      <th>Student</th>
                                      <th>Course</th>
                                      <th>Date</th>
                                  </tr>
                              </thead>
                              <tbody>
                      </HeaderTemplate>
                      <ItemTemplate>
                          <tr>
                              <td>
                                  <div style="display:flex; align-items:center; gap:8px;">
                                      <div style="width:30px; height:30px; border-radius:50%; background:#F5F3FF; color:#7C3AED; font-weight:700; font-size:0.75rem; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                          <%# Server.HtmlEncode(Eval("name").ToString().Substring(0, 1).ToUpper()) %>
                                      </div>
                                      <span><%# Server.HtmlEncode(Eval("name").ToString()) %></span>
                                  </div>
                              </td>
                              <td style="font-size:0.85rem; color:var(--text-light);"><%# Server.HtmlEncode(Eval("course_name").ToString()) %></td>
                              <td style="font-size:0.8rem; color:var(--text-muted); white-space:nowrap;">
                                  <%# Eval("enrolled_date") != DBNull.Value ? Convert.ToDateTime(Eval("enrolled_date")).ToString("dd MMM yyyy") : "-" %>
                              </td>
                          </tr>
                      </ItemTemplate>
                      <FooterTemplate>
                              </tbody>
                          </table>
                      </FooterTemplate>
                  </asp:Repeater>
                  <asp:Label ID="lblNoEnrollments" runat="server" Visible="false"
                      style="display:block; padding:20px; color:var(--text-light); text-align:center;">
                      No enrollments yet.
                  </asp:Label>
              </div>
          </div>

      </div>

      <!-- RIGHT: Sidebar -->
      <div style="display:flex; flex-direction:column; gap:20px;">

          <!-- Quick Actions -->
          <div class="card">
              <div class="card-header"><h3>Quick Actions</h3></div>
              <div class="card-body" style="display:flex; flex-direction:column; gap:8px;">
                  <a href="AdminManageCourses.aspx" class="quick-action-btn">
                      <span>&#43;</span> Add Course
                  </a>
                  <a href="AdminManageLessons.aspx" class="quick-action-btn">
                      <span>&#43;</span> Add Lesson
                  </a>
                  <a href="AdminManageQuizzes.aspx" class="quick-action-btn">
                      <span>&#43;</span> Add Quiz
                  </a>
                  <a href="AdminManageUsers.aspx" class="quick-action-btn outline">
                      <span>&#128101;</span> Manage Users
                  </a>
              </div>
          </div>

          <!-- Top Courses -->
          <div class="card">
              <div class="card-header"><h3>&#127942; Top Courses</h3></div>
              <div class="card-body" style="padding:0 4px;">
                  <asp:Repeater ID="rptTopCourses" runat="server">
                      <ItemTemplate>
                          <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 16px; border-bottom:1px solid #F1F5F9;">
                              <div style="font-size:0.88rem; font-weight:500; color:var(--text);">
                                  <%# Server.HtmlEncode(Eval("course_name").ToString()) %>
                              </div>
                              <div style="background:#F5F3FF; color:#6D28D9; padding:3px 10px; border-radius:12px; font-size:0.75rem; font-weight:600; white-space:nowrap;">
                                  <%# Eval("enroll_count") %> enrolled
                              </div>
                          </div>
                      </ItemTemplate>
                  </asp:Repeater>
              </div>
          </div>

          <!-- Platform Summary -->
          <div class="card">
              <div class="card-header"><h3>Platform Summary</h3></div>
              <div class="card-body" style="padding:0;">
                  <div style="display:flex; justify-content:space-between; padding:10px 16px; border-bottom:1px solid #F1F5F9; font-size:0.85rem;">
                      <span style="color:var(--text-light);">Total Lessons</span>
                      <strong><asp:Literal ID="litTotalLessons" runat="server">0</asp:Literal></strong>
                  </div>
                  <div style="display:flex; justify-content:space-between; padding:10px 16px; border-bottom:1px solid #F1F5F9; font-size:0.85rem;">
                      <span style="color:var(--text-light);">Quiz Attempts</span>
                      <strong><asp:Literal ID="litQuizAttempts" runat="server">0</asp:Literal></strong>
                  </div>
                  <div style="display:flex; justify-content:space-between; padding:10px 16px; font-size:0.85rem;">
                      <span style="color:var(--text-light);">Avg Quiz Score</span>
                      <strong><asp:Literal ID="litAvgScore" runat="server">0</asp:Literal>%</strong>
                  </div>
              </div>
          </div>

      </div>
    </div>

  </div>
</div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="cphScripts" runat="server">
<script type="text/javascript">
    window.addEventListener('load', function () {
        var trendData = <%= GetEnrollmentTrendJson() %>;
        if (trendData && trendData.labels && trendData.labels.length > 0) {
            renderBarChart('enrollmentTrendChart', trendData.labels, trendData.values, null);
        } else {
            document.getElementById('enrollmentTrendChart').innerHTML =
                '<div class="chart-placeholder"><span style="font-size:1.5rem">&#128200;</span><span>No enrollment data yet</span></div>';
        }
    });
</script>
</asp:Content>
