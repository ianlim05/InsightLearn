<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminManageUsers.aspx.cs" Inherits="AdminManageUsers"
    MasterPageFile="~/AdminSite.master" Title="Manage Users" %>
<%--
    Author:      Ian Lim
    Description: User management page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">
    Manage Users
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="admin-page">
  <div class="container">

    <div class="admin-page-header">
        <h1>Manage Users</h1>
        <p>View, add, edit and delete platform users.</p>
    </div>

    <!-- Stats Bar -->
    <div class="admin-stats-bar">
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#6D28D9; font-size:1.1rem;">&#128101;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountTotal" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Total Users</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#EDE9FE; color:#5B21B6; font-size:1.1rem;">&#127891;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountStudents" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Students</div>
            </div>
        </div>
        <div class="admin-stat-chip">
            <div class="asc-icon" style="background:#D1FAE5; color:#065F46; font-size:1.1rem;">&#128274;</div>
            <div class="asc-info">
                <div class="asc-num"><asp:Literal ID="litCountAdmins" runat="server">0</asp:Literal></div>
                <div class="asc-lbl">Admins</div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <asp:Label ID="lblMessage" runat="server" Visible="false"
        style="display:block; margin-bottom:16px;" />

    <!-- Search + Filter Bar -->
    <div class="action-bar">
        <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-control" style="width:150px;"
                AutoPostBack="true" OnSelectedIndexChanged="ddlRoleFilter_Changed">
                <asp:ListItem Value="">All Roles</asp:ListItem>
                <asp:ListItem Value="student">Student</asp:ListItem>
                <asp:ListItem Value="admin">Admin</asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                placeholder="Search by name or email..." style="width:260px;" />
            <asp:Button ID="btnSearch" runat="server" Text="Search"
                OnClick="btnSearch_Click" CssClass="btn btn-primary btn-sm" />
            <asp:Button ID="btnClearSearch" runat="server" Text="Clear"
                OnClick="btnClearSearch_Click" CssClass="btn btn-outline btn-sm" />
        </div>
        <asp:Button ID="btnShowAdd" runat="server" Text="&#43; Add New User"
            OnClick="btnShowAdd_Click" CssClass="btn btn-primary" />
    </div>

    <!-- Add User Form -->
    <asp:Panel ID="pnlAddUser" runat="server" Visible="false" CssClass="details-insert-card">
        <h3>Add New User</h3>
        <div class="form-row">
            <div class="form-group">
                <label>Full Name *</label>
                <asp:TextBox ID="txtAddName" runat="server" CssClass="form-control"
                    placeholder="Enter full name" MaxLength="100" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddName"
                    ValidationGroup="AddUser" CssClass="field-validator"
                    ErrorMessage="Full name is required." Display="Dynamic">Full name is required.</asp:RequiredFieldValidator>
            </div>
            <div class="form-group">
                <label>Email Address *</label>
                <asp:TextBox ID="txtAddEmail" runat="server" CssClass="form-control"
                    placeholder="user@example.com" MaxLength="200" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddEmail"
                    ValidationGroup="AddUser" CssClass="field-validator"
                    ErrorMessage="Email is required." Display="Dynamic">Email is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtAddEmail"
                    ValidationGroup="AddUser" CssClass="field-validator"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email." Display="Dynamic">Enter a valid email.</asp:RegularExpressionValidator>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>Password *</label>
                <asp:TextBox ID="txtAddPassword" runat="server" CssClass="form-control"
                    TextMode="Password" placeholder="Min 6 characters" MaxLength="100" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddPassword"
                    ValidationGroup="AddUser" CssClass="field-validator"
                    ErrorMessage="Password is required." Display="Dynamic">Password is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtAddPassword"
                    ValidationGroup="AddUser" CssClass="field-validator"
                    ValidationExpression="^.{6,}$"
                    ErrorMessage="Password must be at least 6 characters." Display="Dynamic">Password must be at least 6 characters.</asp:RegularExpressionValidator>
            </div>
            <div class="form-group">
                <label>Role *</label>
                <asp:DropDownList ID="ddlAddRole" runat="server" CssClass="form-control">
                    <asp:ListItem Value="student" Selected="True">Student</asp:ListItem>
                    <asp:ListItem Value="admin">Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <asp:ValidationSummary runat="server" ValidationGroup="AddUser"
            CssClass="validation-summary" HeaderText="Please fix the following errors:" />
        <div style="display:flex; gap:10px; margin-top:8px;">
            <asp:Button ID="btnAddUser" runat="server" Text="Add User"
                OnClick="btnAddUser_Click" CssClass="btn btn-primary" ValidationGroup="AddUser" />
            <asp:Button ID="btnCancelAdd" runat="server" Text="Cancel"
                OnClick="btnCancelAdd_Click" CssClass="btn btn-outline" CausesValidation="false" />
        </div>
    </asp:Panel>

    <!-- Edit User Form -->
    <asp:Panel ID="pnlEditUser" runat="server" Visible="false" CssClass="details-insert-card">
        <h3>Edit User</h3>
        <asp:HiddenField ID="hdnEditUserId" runat="server" />
        <div class="form-row">
            <div class="form-group">
                <label>Full Name *</label>
                <asp:TextBox ID="txtEditName" runat="server" CssClass="form-control" MaxLength="100" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditName"
                    ValidationGroup="EditUser" CssClass="field-validator"
                    ErrorMessage="Full name is required." Display="Dynamic">Full name is required.</asp:RequiredFieldValidator>
            </div>
            <div class="form-group">
                <label>Email Address *</label>
                <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" MaxLength="200" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditEmail"
                    ValidationGroup="EditUser" CssClass="field-validator"
                    ErrorMessage="Email is required." Display="Dynamic">Email is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEditEmail"
                    ValidationGroup="EditUser" CssClass="field-validator"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email." Display="Dynamic">Enter a valid email.</asp:RegularExpressionValidator>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>Role *</label>
                <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-control">
                    <asp:ListItem Value="student">Student</asp:ListItem>
                    <asp:ListItem Value="admin">Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <asp:ValidationSummary runat="server" ValidationGroup="EditUser"
            CssClass="validation-summary" HeaderText="Please fix the following errors:" />
        <div style="display:flex; gap:10px; margin-top:8px;">
            <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                OnClick="btnSaveEdit_Click" CssClass="btn btn-primary" ValidationGroup="EditUser" />
            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                OnClick="btnCancelEdit_Click" CssClass="btn btn-outline" CausesValidation="false" />
        </div>
    </asp:Panel>

    <!-- Users Grid -->
    <div class="gridview-wrapper">
        <asp:GridView ID="gvUsers" runat="server"
            CssClass="gridview-table"
            AutoGenerateColumns="False"
            DataKeyNames="user_id"
            AllowPaging="True"
            PageSize="10"
            OnPageIndexChanging="gvUsers_PageIndexChanging"
            OnRowCommand="gvUsers_RowCommand"
            EmptyDataText="No users found.">
            <Columns>
                <asp:BoundField DataField="user_id" HeaderText="ID" ReadOnly="True" ItemStyle-Width="50px" />
                <asp:TemplateField HeaderText="Name">
                    <ItemTemplate>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <div class="user-avatar-sm"><%# Server.HtmlEncode(Eval("name").ToString().Length > 0 ? Eval("name").ToString().Substring(0,1).ToUpper() : "?") %></div>
                            <span style="font-weight:500;"><%# Server.HtmlEncode(Eval("name").ToString()) %></span>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="email" HeaderText="Email" />
                <asp:TemplateField HeaderText="Role" ItemStyle-Width="100px">
                    <ItemTemplate>
                        <%# Eval("role").ToString() == "admin"
                            ? "<span class='role-badge role-admin'>Admin</span>"
                            : "<span class='role-badge role-student'>Student</span>" %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Courses" ItemStyle-Width="80px">
                    <ItemTemplate>
                        <%# Eval("role").ToString() == "student"
                            ? "<span style='font-weight:600; color:var(--primary);'>" + Eval("enrolled_courses") + "</span>"
                            : "<span style='color:var(--text-muted);'>&#8212;</span>" %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="150px">
                    <ItemTemplate>
                        <div class="table-actions">
                            <asp:LinkButton ID="lbEdit" runat="server"
                                CommandName="EditUser"
                                CommandArgument='<%# Eval("user_id") %>'
                                CssClass="btn btn-outline btn-sm">
                                <span class="btn-icon">&#9998;</span> Edit
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandName="DeleteUser"
                                CommandArgument='<%# Eval("user_id") %>'
                                CssClass="btn btn-danger btn-sm"
                                OnClientClick="return confirm('Are you sure you want to delete this user? All their data will be removed.');">
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
