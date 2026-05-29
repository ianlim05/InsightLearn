<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminManageQuizzes.aspx.cs" Inherits="AdminManageQuizzes"
    MasterPageFile="~/AdminSite.master" Title="Manage Quizzes" %>
<%--
    Author:      Chan Kar Jun
    Description: Quiz management page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    Manage Quizzes
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="admin-page">
  <div class="container">

    <div class="admin-page-header">
        <h1>Manage Quizzes</h1>
        <p>Create and manage quizzes. Click &ldquo;Questions&rdquo; on any row to manage its questions.</p>
    </div>

    <!-- Stats Bar -->
    <div class="admin-stats-bar">
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#FEF3C7; color:#92400E; font-size:1.1rem;">&#128203;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountQuizzes" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Total Quizzes</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#6D28D9; font-size:1.1rem;">&#10067;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountQuestions" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Total Questions</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#D1FAE5; color:#065F46; font-size:1.1rem;">&#128202;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litAvgQuestions" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Avg per Quiz</div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <asp:Label ID="lblMessage" runat="server" Visible="false"
        style="display:block; margin-bottom:16px;" />

    <!-- ===== QUIZ SECTION ===== -->
    <div class="section-block">
      <div class="action-bar">
          <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
              <asp:DropDownList ID="ddlCourseFilter" runat="server" CssClass="form-control" style="width:250px;"
                  AutoPostBack="true" OnSelectedIndexChanged="ddlCourseFilter_Changed">
                  <asp:ListItem Value="">All Courses</asp:ListItem>
              </asp:DropDownList>
              <asp:TextBox ID="txtQuizSearch" runat="server" CssClass="form-control"
                  placeholder="Search quiz title..." style="width:220px;" />
              <asp:Button ID="btnQuizSearch" runat="server" Text="Search"
                  OnClick="btnQuizSearch_Click" CssClass="btn btn-primary btn-sm" />
              <asp:Button ID="btnQuizClear" runat="server" Text="Clear"
                  OnClick="btnQuizClear_Click" CssClass="btn btn-outline btn-sm" />
          </div>
          <asp:Button ID="btnShowAddQuiz" runat="server" Text="&#43; Add New Quiz"
              OnClick="btnShowAddQuiz_Click" CssClass="btn btn-primary" />
      </div>

      <!-- Add Quiz Form -->
      <asp:Panel ID="pnlAddQuiz" runat="server" Visible="false" CssClass="details-insert-card">
          <h3>Add New Quiz</h3>
          <div class="form-row">
              <div class="form-group">
                  <label>Quiz Title *</label>
                  <asp:TextBox ID="txtAddQuizTitle" runat="server" CssClass="form-control"
                      placeholder="e.g. Python Fundamentals Quiz" MaxLength="200" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddQuizTitle"
                      ValidationGroup="AddQuiz" CssClass="field-validator"
                      ErrorMessage="Quiz title is required." Display="Dynamic">Quiz title is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Course *</label>
                  <asp:DropDownList ID="ddlAddQuizCourse" runat="server" CssClass="form-control">
                      <asp:ListItem Value="">-- Select Course --</asp:ListItem>
                  </asp:DropDownList>
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlAddQuizCourse"
                      ValidationGroup="AddQuiz" CssClass="field-validator"
                      InitialValue="" ErrorMessage="Please select a course." Display="Dynamic">Please select a course.</asp:RequiredFieldValidator>
              </div>
          </div>
          <asp:ValidationSummary runat="server" ValidationGroup="AddQuiz"
              CssClass="validation-summary" HeaderText="Please fix the following errors:" />
          <div style="display:flex; gap:10px; margin-top:8px;">
              <asp:Button ID="btnAddQuiz" runat="server" Text="Add Quiz"
                  OnClick="btnAddQuiz_Click" CssClass="btn btn-primary" ValidationGroup="AddQuiz" />
              <asp:Button ID="btnCancelAddQuiz" runat="server" Text="Cancel"
                  OnClick="btnCancelAddQuiz_Click" CssClass="btn btn-outline" CausesValidation="false" />
          </div>
      </asp:Panel>

      <!-- Edit Quiz Form -->
      <asp:Panel ID="pnlEditQuiz" runat="server" Visible="false" CssClass="details-insert-card">
          <h3>Edit Quiz</h3>
          <asp:HiddenField ID="hdnEditQuizId" runat="server" />
          <div class="form-row">
              <div class="form-group">
                  <label>Quiz Title *</label>
                  <asp:TextBox ID="txtEditQuizTitle" runat="server" CssClass="form-control" MaxLength="200" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditQuizTitle"
                      ValidationGroup="EditQuiz" CssClass="field-validator"
                      ErrorMessage="Quiz title is required." Display="Dynamic">Quiz title is required.</asp:RequiredFieldValidator>
              </div>
              <div class="form-group">
                  <label>Course *</label>
                  <asp:DropDownList ID="ddlEditQuizCourse" runat="server" CssClass="form-control" />
              </div>
          </div>
          <asp:ValidationSummary runat="server" ValidationGroup="EditQuiz"
              CssClass="validation-summary" HeaderText="Please fix the following errors:" />
          <div style="display:flex; gap:10px; margin-top:8px;">
              <asp:Button ID="btnSaveEditQuiz" runat="server" Text="Save Changes"
                  OnClick="btnSaveEditQuiz_Click" CssClass="btn btn-primary" ValidationGroup="EditQuiz" />
              <asp:Button ID="btnCancelEditQuiz" runat="server" Text="Cancel"
                  OnClick="btnCancelEditQuiz_Click" CssClass="btn btn-outline" CausesValidation="false" />
          </div>
      </asp:Panel>

      <!-- Quizzes Grid -->
      <div class="gridview-wrapper">
          <asp:GridView ID="gvQuizzes" runat="server"
              CssClass="gridview-table"
              AutoGenerateColumns="False"
              DataKeyNames="quiz_id"
              AllowPaging="True"
              PageSize="8"
              OnPageIndexChanging="gvQuizzes_PageIndexChanging"
              OnRowCommand="gvQuizzes_RowCommand"
              EmptyDataText="No quizzes found.">
              <Columns>
                  <asp:BoundField DataField="quiz_id"    HeaderText="ID"           ItemStyle-Width="50px" />
                  <asp:BoundField DataField="quiz_title" HeaderText="Quiz Title"    />
                  <asp:BoundField DataField="course_name" HeaderText="Course"       />
                  <asp:BoundField DataField="question_count" HeaderText="Questions" ItemStyle-Width="100px" />
                  <asp:TemplateField HeaderText="Actions" ItemStyle-Width="230px">
                      <ItemTemplate>
                          <div class="table-actions">
                              <asp:LinkButton ID="lbManageQ" runat="server"
                                  CommandName="ManageQ"
                                  CommandArgument='<%# Eval("quiz_id") %>'
                                  CssClass="btn btn-primary btn-sm">
                                  <span class="btn-icon">&#10067;</span> Questions
                              </asp:LinkButton>
                              <asp:LinkButton ID="lbEditQuiz" runat="server"
                                  CommandName="EditQuiz"
                                  CommandArgument='<%# Eval("quiz_id") %>'
                                  CssClass="btn btn-outline btn-sm">
                                  <span class="btn-icon">&#9998;</span> Edit
                              </asp:LinkButton>
                              <asp:LinkButton ID="lbDeleteQuiz" runat="server"
                                  CommandName="DeleteQuiz"
                                  CommandArgument='<%# Eval("quiz_id") %>'
                                  CssClass="btn btn-danger btn-sm"
                                  OnClientClick="return confirm('Delete this quiz and all its questions?');">
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
