<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentDashboard.aspx.cs" Inherits="StudentDashboard"
    MasterPageFile="~/Site.master" Title="My Dashboard" %>
<%--
    Author:      Oswald Loh Kar Tzun
    Description: Student progress dashboard (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">My Dashboard</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="dashboard-page">
  <div class="container">

    <!-- Page Header -->
    <div class="page-header">
        <h1>My Learning Dashboard</h1>
        <p>Welcome back, <strong><asp:Label ID="lblWelcome" runat="server" /></strong></p>
    </div>

    <!-- ===== STATS CARDS (Dynamic from DB) ===== -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue">&#128218;</div>
            <div class="stat-info">
                <div class="stat-value"><asp:Label ID="lblCoursesEnrolled" runat="server">0</asp:Label></div>
                <div class="stat-label">Courses Enrolled</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">&#10003;</div>
            <div class="stat-info">
                <div class="stat-value"><asp:Label ID="lblLessonsCompleted" runat="server">0</asp:Label></div>
                <div class="stat-label">Lessons Completed</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon orange">&#128394;</div>
            <div class="stat-info">
                <div class="stat-value"><asp:Label ID="lblQuizzesTaken" runat="server">0</asp:Label></div>
                <div class="stat-label">Quizzes Taken</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple">&#11088;</div>
            <div class="stat-info">
                <div class="stat-value"><asp:Label ID="lblAvgScore" runat="server">0</asp:Label>%</div>
                <div class="stat-label">Average Score</div>
            </div>
        </div>
    </div>

    <!-- ===== MAIN CONTENT + SIDEBAR GRID ===== -->
    <div class="dashboard-grid">

      <!-- LEFT: Main content -->
      <div class="dashboard-main">

        <!-- MY COURSES -->
        <div class="section-heading">
            My Courses
            <a href="CourseList.aspx">View All &rarr;</a>
        </div>

        <!-- Enrolled courses with progress bars -->
        <asp:Repeater ID="rptMyCourses" runat="server" OnItemCommand="rptMyCourses_ItemCommand">
            <ItemTemplate>
                <div class="course-progress-item">
                    <div class="cpi-top">
                        <div>
                            <div class="cpi-title"><%# Server.HtmlEncode(Eval("course_name").ToString()) %></div>
                            <div class="cpi-next">
                                <%# Eval("next_lesson") != null && Eval("next_lesson").ToString() != "" ? "Next: " + Server.HtmlEncode(Eval("next_lesson").ToString()) : "All lessons completed!" %>
                            </div>
                        </div>
                        <asp:LinkButton ID="btnContinue" runat="server"
                            CommandName="Continue"
                            CommandArgument='<%# Eval("course_id") %>'
                            CssClass="btn btn-primary btn-sm">Continue</asp:LinkButton>
                    </div>
                    <div class="progress-bar-wrap">
                        <div class="progress-bar-fill"
                             style='width:<%# Eval("progress_pct") %>%'
                             data-width='<%# Eval("progress_pct") %>%'></div>
                    </div>
                    <div class="progress-label"><%# Eval("progress_pct") %>% Complete</div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- No courses enrolled message -->
        <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
            <div class="empty-state">
                <div class="empty-icon">&#128218;</div>
                <h3>No courses yet</h3>
                <p>Start learning by enrolling in a course.</p>
                <a href="CourseList.aspx" class="btn btn-primary mt-2">Browse Courses</a>
            </div>
        </asp:Panel>

        <!-- RECENT QUIZ RESULTS TABLE -->
        <div class="section-heading" style="margin-top:28px;">
            Recent Quiz Results
        </div>

        <div class="card">
          <div class="gridview-scroll">
            <asp:GridView ID="gvQuizResults" runat="server"
                CssClass="data-table"
                AutoGenerateColumns="False"
                GridLines="None"
                EmptyDataText="No quiz attempts yet."
                EmptyDataRowStyle-CssClass="empty-state">
                <Columns>
                    <asp:BoundField DataField="course_name" HeaderText="Course" />
                    <asp:BoundField DataField="quiz_title"  HeaderText="Quiz" />
                    <asp:BoundField DataField="attempt_date" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="score" HeaderText="Score" ItemStyle-CssClass="text-center" />
                    <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="text-center">
                        <ItemTemplate>
                            <span class='<%# (int)Eval("score") >= 70 ? "badge badge-success" : "badge badge-danger" %>'>
                                <%# (int)Eval("score") >= 70 ? "&#10003; PASSED" : "&#10007; FAILED" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
          </div>
        </div>

        <!-- PERFORMANCE CHART -->
        <div class="section-heading" style="margin-top:28px;">
            Performance Over Time
        </div>
        <div class="card">
            <div class="card-body">
                <p style="font-size:0.85rem; color:#64748B; margin-bottom:12px;">Quiz Scores Over Time</p>
                <!-- SVG chart rendered by JavaScript -->
                <div id="performanceChart" style="width:100%; min-height:180px;"></div>
            </div>
        </div>

      </div><!-- /dashboard-main -->

      <!-- RIGHT: Sidebar -->
      <div class="dashboard-sidebar">

        <!-- LEARNING STREAK -->
        <div class="card admin-sidebar-card">
            <h4>&#128293; Learning Streak</h4>
            <div class="streak-widget">
                <div class="streak-number"><asp:Label ID="lblStreak" runat="server">0</asp:Label></div>
                <div class="streak-label">days in a row</div>
                <div class="streak-flame">&#128293;</div>
            </div>
        </div>

        <!-- ACHIEVEMENTS -->
        <div class="card admin-sidebar-card">
            <h4>&#127942; Recent Achievements</h4>
            <asp:Repeater ID="rptAchievements" runat="server">
                <ItemTemplate>
                    <div class="achievement-item">
                        <div class="ach-icon" style="background:<%# Eval("color") %>;">
                            <%# Eval("icon") %>
                        </div>
                        <div>
                            <div class="ach-title"><%# Eval("title") %></div>
                            <div class="ach-desc"><%# Eval("desc") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- RECOMMENDATIONS -->
        <div class="card admin-sidebar-card">
            <h4>&#128161; Recommended For You</h4>
            <asp:Repeater ID="rptRecommendations" runat="server">
                <ItemTemplate>
                    <div class="recommendation-item">
                        <div class="rec-title"><%# Server.HtmlEncode(Eval("course_name").ToString()) %></div>
                        <div class="rec-reason"><%# Server.HtmlEncode(Eval("rec_reason").ToString()) %></div>
                        <a href='CourseList.aspx?courseId=<%# Eval("course_id") %>' class="rec-link">Learn More &rarr;</a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlNoRec" runat="server" Visible="false">
                <div style="text-align:center; padding:16px 0; color:var(--text-light); font-size:0.85rem;">
                    &#127881; You&#39;ve explored all our courses!<br />
                    <a href="CourseList.aspx" style="color:var(--primary); font-weight:600;">Browse Courses</a>
                </div>
            </asp:Panel>
        </div>

        <!-- QUICK ACTIONS -->
        <div class="card admin-sidebar-card">
            <h4>&#9889; Quick Actions</h4>
            <a href="CourseList.aspx" class="quick-action-btn">Browse Courses</a>
            <a href="Certificate.aspx" class="quick-action-btn outline">View Certificates</a>
            <asp:LinkButton ID="lbDashboardLogout" runat="server"
                CssClass="quick-action-btn outline"
                OnClick="lbDashboardLogout_Click"
                OnClientClick="return confirm('Log out?');"
                CausesValidation="false">Logout</asp:LinkButton>
        </div>

      </div><!-- /sidebar -->
    </div><!-- /dashboard-grid -->

  </div><!-- /container -->
</div><!-- /dashboard-page -->

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="cphScripts" runat="server">
<script type="text/javascript">
    // Render performance bar chart using quiz score data from server
    window.addEventListener('load', function () {
        var chartData = <%= GetChartDataJson() %>;
        if (chartData && chartData.labels && chartData.labels.length > 0) {
            renderBarChart('performanceChart', chartData.labels, chartData.values, 100);
        } else {
            document.getElementById('performanceChart').innerHTML =
                '<div class="chart-placeholder"><span style="font-size:1.5rem">&#128202;</span><span>No quiz data available yet</span></div>';
        }
    });
</script>
</asp:Content>
