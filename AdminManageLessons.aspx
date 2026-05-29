<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminManageLessons.aspx.cs" Inherits="AdminManageLessons"
    MasterPageFile="~/AdminSite.master" Title="Manage Lessons" %>
<%--
    Author:      Foo Kim Chean
    Description: Lesson management page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    Manage Lessons
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="admin-page">
  <div class="container">

    <div class="admin-page-header">
        <h1>Manage Lessons</h1>
        <p>Add, edit and remove lessons from courses.</p>
    </div>

    <!-- Stats Bar -->
    <div class="admin-stats-bar">
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#6D28D9; font-size:1.1rem;">&#128214;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountLessons" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Total Lessons</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#D1FAE5; color:#065F46; font-size:1.1rem;">&#127902;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountWithVideo" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">With Video</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#5B21B6; font-size:1.1rem;">&#128218;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountCourses" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Courses</div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <asp:Label ID="lblMessage" runat="server" Visible="false"
        style="display:block; margin-bottom:16px;" />

    <!-- Filter + Add Bar -->
    <div class="action-bar">
        <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
            <asp:DropDownList ID="ddlCourseFilter" runat="server" CssClass="form-control" style="width:250px;"
                AutoPostBack="true" OnSelectedIndexChanged="ddlCourseFilter_Changed">
                <asp:ListItem Value="">All Courses</asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                placeholder="Search lesson title..." style="width:220px;" />
            <asp:Button ID="btnSearch" runat="server" Text="Search"
                OnClick="btnSearch_Click" CssClass="btn btn-primary btn-sm" />
            <asp:Button ID="btnClear" runat="server" Text="Clear"
                OnClick="btnClear_Click" CssClass="btn btn-outline btn-sm" />
        </div>
        <asp:Button ID="btnShowAdd" runat="server" Text="&#43; Add New Lesson"
            OnClick="btnShowAdd_Click" CssClass="btn btn-primary" />
    </div>

    <!-- Add Lesson Form -->
    <asp:Panel ID="pnlAddLesson" runat="server" Visible="false" CssClass="details-insert-card">
        <h3>Add New Lesson</h3>
        <div class="form-row">
            <div class="form-group">
                <label>Course *</label>
                <asp:DropDownList ID="ddlAddCourse" runat="server" CssClass="form-control">
                    <asp:ListItem Value="">-- Select Course --</asp:ListItem>
                </asp:DropDownList>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlAddCourse"
                    ValidationGroup="AddLesson" CssClass="field-validator"
                    InitialValue="" ErrorMessage="Please select a course." Display="Dynamic">Please select a course.</asp:RequiredFieldValidator>
            </div>
            <div class="form-group">
                <label>Lesson Title *</label>
                <asp:TextBox ID="txtAddTitle" runat="server" CssClass="form-control"
                    placeholder="e.g. Variables and Data Types" MaxLength="200" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddTitle"
                    ValidationGroup="AddLesson" CssClass="field-validator"
                    ErrorMessage="Lesson title is required." Display="Dynamic">Lesson title is required.</asp:RequiredFieldValidator>
            </div>
        </div>
        <div class="form-group">
            <label>Video URL <small style="color:var(--text-light);">(YouTube embed URL &mdash; optional)</small></label>
            <asp:TextBox ID="txtAddVideoUrl" runat="server" CssClass="form-control"
                placeholder="https://www.youtube.com/embed/..." MaxLength="500" />
        </div>
        <div class="form-group">
            <label>Lesson Content *</label>
            <asp:TextBox ID="txtAddContent" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="5"
                placeholder="Enter lesson content / overview..." MaxLength="5000" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddContent"
                ValidationGroup="AddLesson" CssClass="field-validator"
                ErrorMessage="Lesson content is required." Display="Dynamic">Lesson content is required.</asp:RequiredFieldValidator>
        </div>
        <asp:ValidationSummary runat="server" ValidationGroup="AddLesson"
            CssClass="validation-summary" HeaderText="Please fix the following errors:" />
        <div style="display:flex; gap:10px; margin-top:8px;">
            <asp:Button ID="btnAddLesson" runat="server" Text="Add Lesson"
                OnClick="btnAddLesson_Click" CssClass="btn btn-primary" ValidationGroup="AddLesson" />
            <asp:Button ID="btnCancelAdd" runat="server" Text="Cancel"
                OnClick="btnCancelAdd_Click" CssClass="btn btn-outline" CausesValidation="false" />
        </div>
    </asp:Panel>

    <!-- Edit Lesson Form -->
    <asp:Panel ID="pnlEditLesson" runat="server" Visible="false" CssClass="details-insert-card">
        <h3>Edit Lesson</h3>
        <asp:HiddenField ID="hdnEditLessonId" runat="server" />
        <div class="form-row">
            <div class="form-group">
                <label>Course *</label>
                <asp:DropDownList ID="ddlEditCourse" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <label>Lesson Title *</label>
                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" MaxLength="200" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditTitle"
                    ValidationGroup="EditLesson" CssClass="field-validator"
                    ErrorMessage="Lesson title is required." Display="Dynamic">Lesson title is required.</asp:RequiredFieldValidator>
            </div>
        </div>
        <div class="form-group">
            <label>Video URL <small style="color:var(--text-light);">(YouTube embed URL &mdash; optional)</small></label>
            <asp:TextBox ID="txtEditVideoUrl" runat="server" CssClass="form-control" MaxLength="500" />
        </div>
        <div class="form-group">
            <label>Lesson Content *</label>
            <asp:TextBox ID="txtEditContent" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="5" MaxLength="5000" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditContent"
                ValidationGroup="EditLesson" CssClass="field-validator"
                ErrorMessage="Lesson content is required." Display="Dynamic">Lesson content is required.</asp:RequiredFieldValidator>
        </div>
        <asp:ValidationSummary runat="server" ValidationGroup="EditLesson"
            CssClass="validation-summary" HeaderText="Please fix the following errors:" />
        <div style="display:flex; gap:10px; margin-top:8px;">
            <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                OnClick="btnSaveEdit_Click" CssClass="btn btn-primary" ValidationGroup="EditLesson" />
            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                OnClick="btnCancelEdit_Click" CssClass="btn btn-outline" CausesValidation="false" />
        </div>
    </asp:Panel>

    <!-- Lessons Grid -->
    <div class="gridview-wrapper">
        <asp:GridView ID="gvLessons" runat="server"
            CssClass="gridview-table"
            AutoGenerateColumns="False"
            DataKeyNames="lesson_id"
            AllowPaging="True"
            PageSize="10"
            OnPageIndexChanging="gvLessons_PageIndexChanging"
            OnRowCommand="gvLessons_RowCommand"
            EmptyDataText="No lessons found.">
            <Columns>
                <asp:BoundField DataField="lesson_id"    HeaderText="ID"           ItemStyle-Width="50px" />
                <asp:BoundField DataField="course_name"  HeaderText="Course"        />
                <asp:BoundField DataField="lesson_title" HeaderText="Lesson Title"  />
                <asp:TemplateField HeaderText="Video" ItemStyle-Width="80px">
                    <ItemTemplate>
                        <%# !string.IsNullOrEmpty(Eval("video_url").ToString())
                            ? "<span style='color:#10B981;'>&#10003; Yes</span>"
                            : "<span style='color:#94A3B8;'>No</span>" %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="150px">
                    <ItemTemplate>
                        <div class="table-actions">
                            <asp:LinkButton ID="lbEdit" runat="server"
                                CommandName="EditLesson"
                                CommandArgument='<%# Eval("lesson_id") %>'
                                CssClass="btn btn-outline btn-sm">
                                <span class="btn-icon">&#9998;</span> Edit
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandName="DeleteLesson"
                                CommandArgument='<%# Eval("lesson_id") %>'
                                CssClass="btn btn-danger btn-sm"
                                OnClientClick="return confirm('Delete this lesson? Student progress for this lesson will also be removed.');">
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

</asp:Content>
