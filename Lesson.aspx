<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Lesson.aspx.cs" Inherits="Lesson"
    MasterPageFile="~/Site.master" Title="Lesson" %>
<%--
    Author:      Foo Kim Chean
    Description: Student lesson viewer page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    <asp:Literal ID="litTitle" runat="server">Lesson</asp:Literal>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="lesson-page">
  <div class="container">

    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="Default.aspx">Home</a>
        <span class="sep">&#8250;</span>
        <a href="CourseList.aspx">Courses</a>
        <span class="sep">&#8250;</span>
        <a id="aCourseBread" runat="server" href="#">
            <asp:Literal ID="litCourseName" runat="server" />
        </a>
        <span class="sep">&#8250;</span>
        <span class="current"><asp:Literal ID="litLessonBread" runat="server">Lesson</asp:Literal></span>
    </div>

    <!-- Not enrolled message -->
    <asp:Panel ID="pnlNotEnrolled" runat="server" Visible="false">
        <div class="alert alert-warning">
            &#9888; You are not enrolled in this course.
            <a href="CourseList.aspx" class="btn btn-primary btn-sm" style="margin-left:12px;">Browse Courses</a>
        </div>
    </asp:Panel>

    <!-- Hidden field preserves resolved lessonId across postbacks -->
    <asp:HiddenField ID="hdnCurrentLessonId" runat="server" Value="0" />

    <!-- Main lesson content (hidden if not enrolled) -->
    <asp:Panel ID="pnlLesson" runat="server">
      <div class="lesson-layout">

        <!-- ===== LEFT: Main Content ===== -->
        <div class="lesson-main">

          <!-- VIDEO PLAYER -->
          <div class="video-container" id="videoContainer">
              <asp:PlaceHolder ID="phVideo" runat="server" />
          </div>
          <div id="videoNote" style="display:none; font-size:0.8rem; color:var(--text-light); margin-top:6px; padding:0 4px;">
              &#9888; If the video is unavailable, it may be region-restricted. The lesson content below covers the same material.
          </div>
          <script type="text/javascript">
              (function () {
                  var iframe = document.querySelector('#videoContainer iframe');
                  if (iframe) {
                      // Show the note after 4 seconds (YouTube loads quickly if available)
                      setTimeout(function () {
                          document.getElementById('videoNote').style.display = 'block';
                      }, 4000);
                  }
              })();
          </script>

          <!-- LESSON INFORMATION BLOCK -->
          <div class="lesson-info-block">
              <h2><asp:Literal ID="litLessonTitle" runat="server">Lesson Title</asp:Literal></h2>
              <div class="lesson-meta-tags">
                  <span>&#128337; <asp:Literal ID="litDuration" runat="server">15 min</asp:Literal></span>
                  <span>&#128218; <asp:Literal ID="litCourseMeta" runat="server" /></span>
                  <span>&#128202; Progress: <asp:Literal ID="litProgress" runat="server">0%</asp:Literal></span>
              </div>
          </div>

          <!-- LESSON CONTENT / TRANSCRIPT -->
          <div class="lesson-content-block">
              <h3>Lesson Overview</h3>
              <p><asp:Literal ID="litContent" runat="server">Lesson content loading...</asp:Literal></p>
          </div>

          <!-- BOTTOM NAVIGATION BUTTONS -->
          <div class="lesson-nav-bar">
              <asp:Button ID="btnPrevLesson" runat="server"
                  Text="&larr; Previous Lesson"
                  OnClick="btnPrevLesson_Click"
                  CssClass="btn btn-outline" />

              <asp:Button ID="btnMarkComplete" runat="server"
                  Text="Mark as Complete"
                  OnClick="btnMarkComplete_Click"
                  CssClass="btn btn-success" />

              <asp:Button ID="btnNextLesson" runat="server"
                  Text="Next Lesson &rarr;"
                  OnClick="btnNextLesson_Click"
                  CssClass="btn btn-primary" />
          </div>

          <!-- Mark as complete message -->
          <asp:Label ID="lblCompleteMsg" runat="server" CssClass="alert alert-success"
              Visible="false" EnableViewState="false" style="display:block; margin-top:14px;" />

        </div><!-- /lesson-main -->

        <!-- ===== RIGHT: Sidebar ===== -->
        <div class="lesson-sidebar">

          <!-- OVERALL PROGRESS CARD -->
          <div class="card progress-card">
            <div class="card-header">
                <h3>Overall Progress</h3>
            </div>

            <div class="card-body">
                <div class="progress-top">
                    <span class="label">Completed</span>
                    <span class="pct">
                        <asp:Label ID="lblProgressPct" runat="server">0</asp:Label>%
                    </span>
                </div>

                <div class="progress-bar-wrap">
                    <div class="progress-bar-fill" id="progressFill" runat="server"></div>
                </div>

                <div class="progress-note">
                    <asp:Literal ID="litCompletedCount" runat="server">0</asp:Literal> of
                    <asp:Literal ID="litTotalLessons" runat="server">0</asp:Literal> lessons completed
                </div>
            </div>
        </div>

          <!-- LESSON LIST -->
          <div class="card lesson-list-card">
              <div class="card-header"><h3>Course Lessons</h3></div>
              <div class="card-body" style="padding:8px 0;">
                  <asp:Repeater ID="rptLessonList" runat="server">
                      <ItemTemplate>
                          <a href='Lesson.aspx?courseId=<%# Eval("course_id") %>&lessonId=<%# Eval("lesson_id") %>'
                             style="text-decoration:none; display:block;">
                              <div class='lesson-list-item <%# (bool)Eval("is_current") ? "active-lesson" : "" %> <%# (bool)Eval("is_completed") ? "completed" : "" %>'>
                                  <div class="lesson-list-num">
                                      <%# (bool)Eval("is_completed") ? "&#10003;" : Eval("lesson_num").ToString() %>
                                  </div>
                                  <div class="lesson-list-text">
                                      <div class="lesson-list-title"><%# Eval("lesson_title") %></div>
                                  </div>
                              </div>
                          </a>
                      </ItemTemplate>
                  </asp:Repeater>
              </div>
          </div>

          <!-- TAKE QUIZ BUTTON -->
          <asp:HyperLink ID="hlTakeQuiz" runat="server"
              CssClass="take-quiz-btn"
              Visible="false">Take Quiz &rarr;</asp:HyperLink>

          <!-- RESOURCES -->
          <div class="card">
              <div class="card-header"><h3>Lesson Resources</h3></div>
              <div class="card-body" style="padding:14px 16px;">
                  <div class="resource-item">&#128196; Lecture Notes</div>
                  <div class="resource-item">&#128190; Code Examples</div>
                  <div class="resource-item">&#128196; Additional Reading</div>
              </div>
          </div>

        </div><!-- /sidebar -->
      </div><!-- /lesson-layout -->
    </asp:Panel>

  </div><!-- /container -->
</div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="cphScripts" runat="server">
<script type="text/javascript">
    // Animate the sidebar progress bar after each postback
    // Use querySelectorAll (not getElementById) because runat="server" mangles the client ID
    window.addEventListener('load', function () {
        var fills = document.querySelectorAll('.progress-bar-fill');
        fills.forEach(function (fill) {
            var target = fill.getAttribute('data-width') || fill.style.width;
            if (target) {
                fill.style.width = '0';
                setTimeout(function () { fill.style.width = target; }, 150);
            }
        });
    });
</script>
</asp:Content>
