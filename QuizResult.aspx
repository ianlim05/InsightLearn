<%@ Page Language="C#" AutoEventWireup="true" CodeFile="QuizResult.aspx.cs" Inherits="QuizResult"
    MasterPageFile="~/Site.master" Title="Quiz Result" %>
<%--
    Author:      Chan Kar Jun
    Description: Quiz result display page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Quiz Result</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="quiz-result-page">

  <!-- ===== HERO SCORE SECTION ===== -->
  <div class="result-hero">
      <h1>&#127941; <asp:Literal ID="litQuizTitle" runat="server">Quiz Result</asp:Literal></h1>

      <!-- Animated score circle -->
      <div class="result-score-circle" id="scoreCircle" runat="server">
          <div class="rsc-num"><asp:Literal ID="litScore" runat="server">0</asp:Literal></div>
          <div class="rsc-pct">% Score</div>
      </div>

      <!-- Pass / Fail badge -->
      <div class="result-badge-row">
          <asp:Label ID="lblPassFail" runat="server" CssClass="result-pass-badge" />
      </div>

      <!-- Correct / Wrong / Total stats -->
      <div class="result-stats-row" style="margin-top:20px;">
          <div class="result-stat">
              <div class="rs-num"><asp:Literal ID="litCorrect" runat="server">0</asp:Literal></div>
              <div class="rs-lbl">Correct</div>
          </div>
          <div class="result-stat" style="border-left:1px solid rgba(255,255,255,0.15); border-right:1px solid rgba(255,255,255,0.15); padding:0 28px;">
              <div class="rs-num"><asp:Literal ID="litWrong" runat="server">0</asp:Literal></div>
              <div class="rs-lbl">Wrong</div>
          </div>
          <div class="result-stat">
              <div class="rs-num"><asp:Literal ID="litTotal" runat="server">0</asp:Literal></div>
              <div class="rs-lbl">Total</div>
          </div>
      </div>
  </div>

  <!-- ===== RESULT BODY ===== -->
  <div class="result-body">

    <!-- Actions Card (overlapping the hero) -->
    <div class="result-actions-card">
        <div class="passing-note">
            Keep studying and try again you need <strong>70%</strong> to pass.
            <asp:Label ID="lblEncouragement" runat="server" style="display:block; margin-top:4px; font-weight:500;" />
        </div>
        <div class="result-action-btns">
            <asp:HyperLink ID="hlRetakeQuiz" runat="server"
                CssClass="btn btn-outline">&#8635; Retake Quiz</asp:HyperLink>
            <asp:HyperLink ID="hlDashboard" runat="server"
                NavigateUrl="StudentDashboard.aspx"
                CssClass="btn btn-primary">&#8592; Dashboard</asp:HyperLink>
        </div>
    </div>

    <!-- Question Review -->
    <div class="result-review-section">
        <h2>Question Review</h2>
        <p class="review-sub">See which questions you got right and which need more study.</p>

        <asp:Repeater ID="rptReview" runat="server">
            <ItemTemplate>
                <div class='review-item <%# (bool)Eval("IsCorrect") ? "review-correct" : "review-wrong" %>'>
                    <div class="review-qnum">
                        <span class='review-icon'><%# (bool)Eval("IsCorrect") ? "&#10003;" : "&#10007;" %></span>
                        Question <%# Eval("QuestionNum") %>
                    </div>
                    <div class="review-qtext">
                        <%# Server.HtmlEncode(Eval("QuestionText").ToString()) %>
                    </div>
                    <div class="review-options">
                        <%# BuildOptionHtml("A", Eval("OptionA").ToString(), Eval("SelectedAnswer").ToString(), Eval("CorrectAnswer").ToString()) %>
                        <%# BuildOptionHtml("B", Eval("OptionB").ToString(), Eval("SelectedAnswer").ToString(), Eval("CorrectAnswer").ToString()) %>
                        <%# BuildOptionHtml("C", Eval("OptionC").ToString(), Eval("SelectedAnswer").ToString(), Eval("CorrectAnswer").ToString()) %>
                        <%# BuildOptionHtml("D", Eval("OptionD").ToString(), Eval("SelectedAnswer").ToString(), Eval("CorrectAnswer").ToString()) %>
                    </div>
                    <%# string.IsNullOrEmpty(Eval("SelectedAnswer").ToString()) ? "<div class='unanswered-note'> This question was not answered.</div>" : "" %>
                </div>
            </ItemTemplate>
        </asp:Repeater>

    </div>
  </div><!-- /result-body -->

</div><!-- /quiz-result-page -->

</asp:Content>
