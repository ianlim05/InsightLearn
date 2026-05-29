<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminManageQuestions.aspx.cs" Inherits="AdminManageQuestions"
    MasterPageFile="~/AdminSite.master" Title="Manage Questions" %>
<%--
    Author:      Oswald Loh Kar Tzun
    Description: Question bank management page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    Manage Questions
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="admin-page">
  <div class="container">

    <!-- Page Header with Back Link -->
    <div class="admin-page-header">
        <div>
            <div class="breadcrumb" style="margin-bottom:6px;">
                <a href="AdminManageQuizzes.aspx">Manage Quizzes</a>
                <span class="sep">&#8250;</span>
                <span class="current">Questions</span>
            </div>
            <h1>Manage Questions</h1>
            <p>Quiz: <strong><asp:Literal ID="litQuizTitleSub" runat="server" /></strong></p>
        </div>
        <a href="AdminManageQuizzes.aspx" class="btn btn-outline">&larr; Back to Quizzes</a>
    </div>

    <!-- Stats Bar -->
    <div class="admin-stats-bar">
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#6D28D9; font-size:1.1rem;">&#10067;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litQCount" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Total Questions</div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <asp:Label ID="lblMessage" runat="server" Visible="false"
        style="display:block; margin-bottom:16px;" />

    <!-- Questions Section -->
    <div class="section-block">
      <div class="action-bar">
          <span style="color:var(--text-light); font-size:0.9rem;">
              Manage questions for this quiz. Students see these during the quiz.
          </span>
          <asp:Button ID="btnShowAddQuestion" runat="server" Text="&#43; Add Question"
              OnClick="btnShowAddQuestion_Click" CssClass="btn btn-primary" />
      </div>

      <!-- Add Question Form -->
      <asp:Panel ID="pnlAddQuestion" runat="server" Visible="false" CssClass="details-insert-card">
          <h3>Add New Question</h3>
          <div class="form-group">
              <label>Question Text *</label>
              <asp:TextBox ID="txtAddQText" runat="server" CssClass="form-control"
                  TextMode="MultiLine" Rows="3"
                  placeholder="Enter the question..." MaxLength="1000" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddQText"
                  ValidationGroup="AddQ" CssClass="field-validator"
                  ErrorMessage="Question text is required." Display="Dynamic">Question text is required.</asp:RequiredFieldValidator>
          </div>
          <div class="form-row">
              <div class="form-group">
                  <label>Option A *</label>
                  <asp:TextBox ID="txtAddOptA" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddOptA"
                      ValidationGroup="AddQ" CssClass="field-validator"
                      ErrorMessage="Option A is required." Display="Dynamic">Option A is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Option B *</label>
                  <asp:TextBox ID="txtAddOptB" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddOptB"
                      ValidationGroup="AddQ" CssClass="field-validator"
                      ErrorMessage="Option B is required." Display="Dynamic">Option B is required.</asp:RequiredFieldValidator>
              </div>
          </div>
          <div class="form-row">
              <div class="form-group">
                  <label>Option C *</label>
                  <asp:TextBox ID="txtAddOptC" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddOptC"
                      ValidationGroup="AddQ" CssClass="field-validator"
                      ErrorMessage="Option C is required." Display="Dynamic">Option C is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Option D *</label>
                  <asp:TextBox ID="txtAddOptD" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddOptD"
                      ValidationGroup="AddQ" CssClass="field-validator"
                      ErrorMessage="Option D is required." Display="Dynamic">Option D is required.</asp:RequiredFieldValidator>
              </div>
          </div>
          <div class="form-group" style="max-width:200px;">
              <label>Correct Answer *</label>
              <asp:DropDownList ID="ddlAddCorrect" runat="server" CssClass="form-control">
                  <asp:ListItem Value="A">A</asp:ListItem>
                  <asp:ListItem Value="B">B</asp:ListItem>
                  <asp:ListItem Value="C">C</asp:ListItem>
                  <asp:ListItem Value="D">D</asp:ListItem>
              </asp:DropDownList>
          </div>
          <asp:ValidationSummary runat="server" ValidationGroup="AddQ"
              CssClass="validation-summary" HeaderText="Please fix the following errors:" />
          <div style="display:flex; gap:10px; margin-top:8px;">
              <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question"
                  OnClick="btnAddQuestion_Click" CssClass="btn btn-primary" ValidationGroup="AddQ" />
              <asp:Button ID="btnCancelAddQ" runat="server" Text="Cancel"
                  OnClick="btnCancelAddQ_Click" CssClass="btn btn-outline" CausesValidation="false" />
          </div>
      </asp:Panel>

      <!-- Edit Question Form -->
      <asp:Panel ID="pnlEditQuestion" runat="server" Visible="false" CssClass="details-insert-card">
          <h3>Edit Question</h3>
          <asp:HiddenField ID="hdnEditQuestionId" runat="server" />
          <div class="form-group">
              <label>Question Text *</label>
              <asp:TextBox ID="txtEditQText" runat="server" CssClass="form-control"
                  TextMode="MultiLine" Rows="3" MaxLength="1000" />
              <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditQText"
                  ValidationGroup="EditQ" CssClass="field-validator"
                  ErrorMessage="Question text is required." Display="Dynamic">Question text is required.</asp:RequiredFieldValidator>
          </div>
          <div class="form-row">
              <div class="form-group">
                  <label>Option A *</label>
                  <asp:TextBox ID="txtEditOptA" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditOptA"
                      ValidationGroup="EditQ" CssClass="field-validator"
                      ErrorMessage="Option A is required." Display="Dynamic">Option A is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Option B *</label>
                  <asp:TextBox ID="txtEditOptB" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditOptB"
                      ValidationGroup="EditQ" CssClass="field-validator"
                      ErrorMessage="Option B is required." Display="Dynamic">Option B is required.</asp:RequiredFieldValidator>
              </div>
          </div>
          <div class="form-row">
              <div class="form-group">
                  <label>Option C *</label>
                  <asp:TextBox ID="txtEditOptC" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditOptC"
                      ValidationGroup="EditQ" CssClass="field-validator"
                      ErrorMessage="Option C is required." Display="Dynamic">Option C is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Option D *</label>
                  <asp:TextBox ID="txtEditOptD" runat="server" CssClass="form-control" MaxLength="500" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditOptD"
                      ValidationGroup="EditQ" CssClass="field-validator"
                      ErrorMessage="Option D is required." Display="Dynamic">Option D is required.</asp:RequiredFieldValidator>
              </div>
          </div>
          <div class="form-group" style="max-width:200px;">
              <label>Correct Answer *</label>
              <asp:DropDownList ID="ddlEditCorrect" runat="server" CssClass="form-control">
                  <asp:ListItem Value="A">A</asp:ListItem>
                  <asp:ListItem Value="B">B</asp:ListItem>
                  <asp:ListItem Value="C">C</asp:ListItem>
                  <asp:ListItem Value="D">D</asp:ListItem>
              </asp:DropDownList>
          </div>
          <asp:ValidationSummary runat="server" ValidationGroup="EditQ"
              CssClass="validation-summary" HeaderText="Please fix the following errors:" />
          <div style="display:flex; gap:10px; margin-top:8px;">
              <asp:Button ID="btnSaveEditQ" runat="server" Text="Save Changes"
                  OnClick="btnSaveEditQ_Click" CssClass="btn btn-primary" ValidationGroup="EditQ" />
              <asp:Button ID="btnCancelEditQ" runat="server" Text="Cancel"
                  OnClick="btnCancelEditQ_Click" CssClass="btn btn-outline" CausesValidation="false" />
          </div>
      </asp:Panel>

      <!-- Questions GridView -->
      <div class="gridview-wrapper">
          <asp:GridView ID="gvQuestions" runat="server"
              CssClass="gridview-table"
              AutoGenerateColumns="False"
              DataKeyNames="question_id"
              AllowPaging="True"
              PageSize="10"
              OnPageIndexChanging="gvQuestions_PageIndexChanging"
              OnRowCommand="gvQuestions_RowCommand"
              EmptyDataText="No questions yet. Click &quot;+ Add Question&quot; to add the first one.">
              <Columns>
                  <asp:BoundField DataField="question_id" HeaderText="ID" ItemStyle-Width="50px" />
                  <asp:TemplateField HeaderText="Question Text">
                      <ItemTemplate>
                          <div style="max-width:460px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                               title='<%# Server.HtmlEncode(Eval("question_text").ToString()) %>'>
                              <%# Server.HtmlEncode(
                                  Eval("question_text").ToString().Length > 90
                                      ? Eval("question_text").ToString().Substring(0, 90) + "..."
                                      : Eval("question_text").ToString()) %>
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="Correct" ItemStyle-Width="80px">
                      <ItemTemplate>
                          <span style="font-weight:700; color:var(--success);">
                              <%# Eval("correct_answer") %>
                          </span>
                      </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="Actions" ItemStyle-Width="160px">
                      <ItemTemplate>
                          <div class="table-actions">
                              <asp:LinkButton ID="lbEditQ" runat="server"
                                  CommandName="EditQ"
                                  CommandArgument='<%# Eval("question_id") %>'
                                  CssClass="btn btn-outline btn-sm">
                                  <span class="btn-icon">&#9998;</span> Edit
                              </asp:LinkButton>
                              <asp:LinkButton ID="lbDeleteQ" runat="server"
                                  CommandName="DeleteQ"
                                  CommandArgument='<%# Eval("question_id") %>'
                                  CssClass="btn btn-danger btn-sm"
                                  OnClientClick="return confirm('Delete this question? This cannot be undone.');">
                                  <span class="btn-icon">&#128465;</span> Delete
                              </asp:LinkButton>
                          </div>
                      </ItemTemplate>
                  </asp:TemplateField>
              </Columns>
              <PagerStyle CssClass="gridview-pager" />
          </asp:GridView>
      </div>
    </div>

  </div>
</div>

</asp:Content>
