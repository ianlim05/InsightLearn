<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Quiz.aspx.cs" Inherits="Quiz"
    MasterPageFile="~/Site.master" Title="Quiz" %>
<%--
    Author:      Chan Kar Jun
    Description: Student quiz-taking page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    <asp:Literal ID="litQuizTitle" runat="server">Quiz</asp:Literal>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<!-- Quiz Header -->
<div class="quiz-header">
  <div class="container">
      <h1><asp:Literal ID="litHeadingTitle" runat="server">Quiz</asp:Literal></h1>
      <p>Test your understanding &mdash; select one answer per question.</p>
  </div>
</div>

<div class="quiz-page">
  <div class="container">

    <!-- Error / info messages -->
    <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger"
        Visible="false" EnableViewState="false" style="display:block;margin-bottom:16px;" />

    <!-- Hidden fields for navigation state -->
    <asp:HiddenField ID="hdnCurrentQ"      runat="server" Value="0" />
    <asp:HiddenField ID="hdnTargetQuestion" runat="server" Value="-1" />

    <asp:Panel ID="pnlQuiz" runat="server">
      <div class="quiz-layout">

        <!-- ===== LEFT: Question Area ===== -->
        <div class="quiz-main">

          <!-- PROGRESS INDICATOR -->
          <div class="quiz-progress-bar">
              <div class="qpb-top">
                  <span class="qpb-label">
                      Question <asp:Literal ID="litQNum" runat="server">1</asp:Literal>
                      of <asp:Literal ID="litQTotal" runat="server">0</asp:Literal>
                  </span>
                  <span class="qpb-time">Answer all questions before submitting</span>
              </div>
              <div class="progress-bar-wrap">
                  <div class="progress-bar-fill"
                       id="quizProgressFill" runat="server"
                       style="width:0%"></div>
              </div>
          </div>

          <!-- QUESTION CARD -->
          <div class="question-card">
              <div class="question-number">
                  Question <asp:Literal ID="litQLabel" runat="server">1</asp:Literal>
              </div>
              <div class="question-text">
                  <asp:Literal ID="litQuestion" runat="server">Loading question...</asp:Literal>
              </div>

              <!-- Multiple choice options -->
              <ul class="options-list">
                  <asp:Repeater ID="rptOptions" runat="server">
                      <ItemTemplate>
                          <li class='option-item <%# IsSelected((string)Eval("key")) ? "selected" : "" %>'>
                              <label>
                                  <input type="radio" name="quizAnswer"
                                         value='<%# Eval("key") %>'
                                         id='opt_<%# Eval("key") %>'
                                         <%# IsSelected((string)Eval("key")) ? "checked=\"checked\"" : "" %> />
                                  <span><%# Eval("key") %>. <%# Server.HtmlEncode(Eval("value").ToString()) %></span>
                              </label>
                          </li>
                      </ItemTemplate>
                  </asp:Repeater>
              </ul>
          </div>

          <!-- NAVIGATION BUTTONS -->
          <div class="quiz-nav-bar">
              <asp:Button ID="btnPrevQ" runat="server"
                  Text="&larr; Previous Question"
                  OnClick="btnPrevQ_Click"
                  CssClass="btn btn-outline" />

              <asp:Button ID="btnFlag" runat="server"
                  Text="Flag for Review"
                  OnClick="btnFlag_Click"
                  CssClass="btn btn-outline btn-flag" />

              <asp:Button ID="btnNextQ" runat="server"
                  Text="Next Question &rarr;"
                  OnClick="btnNextQ_Click"
                  CssClass="btn btn-primary" />

              <asp:Button ID="btnSubmitQuiz" runat="server"
                  Text="Submit Quiz"
                  OnClick="btnSubmitQuiz_Click"
                  CssClass="btn btn-success"
                  Visible="false"
                  OnClientClick="return confirm('Are you sure you want to submit? You cannot change answers after submission.');" />
          </div>

        </div><!-- /quiz-main -->

        <!-- ===== RIGHT: Sidebar ===== -->
        <div class="quiz-sidebar">

          <!-- QUIZ INFORMATION -->
          <div class="card quiz-info-card">
              <div class="card-header"><h3>Quiz Details</h3></div>
              <div class="card-body" style="padding:0 4px;">
                  <div class="quiz-info-row">
                      <span>Total Questions</span>
                      <span class="value"><asp:Literal ID="litTotalQ" runat="server">0</asp:Literal></span>
                  </div>
                  <div class="quiz-info-row">
                      <span>Passing Score</span>
                      <span class="value">70%</span>
                  </div>
                  <div class="quiz-info-row">
                      <span>Answered</span>
                      <span class="value"><asp:Literal ID="litAnsweredCount" runat="server">0</asp:Literal></span>
                  </div>
              </div>
          </div>

          <!-- QUESTION NAVIGATOR -->
          <div class="q-navigator">
              <h4>All Questions</h4>
              <div class="q-nav-grid" id="qNavGrid">
                  <asp:Repeater ID="rptQNav" runat="server">
                      <ItemTemplate>
                          <button type="button"
                                  class='q-nav-btn <%# GetNavBtnClass((int)Eval("index")) %>'
                                  data-question='<%# Eval("index") %>'>
                              <%# ((int)Eval("index")) + 1 %>
                          </button>
                      </ItemTemplate>
                  </asp:Repeater>
              </div>
              <div class="q-nav-legend">
                  <div class="q-nav-legend-item">
                      <div class="legend-dot" style="background:#7C3AED;"></div> Current
                  </div>
                  <div class="q-nav-legend-item">
                      <div class="legend-dot" style="background:#ECFDF5; border:1px solid #10B981;"></div> Answered
                  </div>
                  <div class="q-nav-legend-item">
                      <div class="legend-dot" style="background:#F59E0B;"></div> Flagged
                  </div>
                  <div class="q-nav-legend-item">
                      <div class="legend-dot" style="background:#F1F5F9; border:1px solid #E2E8F0;"></div> Not Answered
                  </div>
              </div>
          </div>

          <!-- INSTRUCTIONS -->
          <div class="card instructions-card">
              <h4>Instructions</h4>
              <ul>
                  <li>Read each question carefully</li>
                  <li>Select one answer per question</li>
                  <li>You can navigate between questions</li>
                  <li>Flag questions to review later</li>
                  <li>Submit when complete</li>
              </ul>
          </div>

        </div><!-- /quiz-sidebar -->
      </div><!-- /quiz-layout -->

      <!-- Hidden navigate button for JS calls -->
      <asp:Button ID="btnNavigate" runat="server" Style="display:none;"
          OnClick="btnNavigate_Click" />

    </asp:Panel>

  </div><!-- /container -->
</div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="cphScripts" runat="server">
<script type="text/javascript">
    // Override navigateToQuestion from scripts.js with correct master-page client IDs
    function navigateToQuestion(qNum) {
        var hdnTarget = document.getElementById('<%= hdnTargetQuestion.ClientID %>');
        var btnNav    = document.getElementById('<%= btnNavigate.ClientID %>');
        if (hdnTarget && btnNav) {
            hdnTarget.value = qNum;
            btnNav.click();
        }
    }
</script>
</asp:Content>
