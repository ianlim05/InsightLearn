<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseList.aspx.cs" Inherits="CourseList"
    MasterPageFile="~/Site.master" Title="All Courses" %>
<%--
    Author:      Ng Ern Chi
    Description: Student course listing page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">All Courses</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<div class="course-list-page">
  <div class="container">

    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="Default.aspx">Home</a>
        <span class="sep">&#8250;</span>
        <span class="current">Courses</span>
    </div>

    <!-- Page heading -->
    <div class="page-header">
        <h1>All Courses</h1>
        <p>Discover our wide range of courses designed to help you grow.</p>
    </div>

    <%-- feedback label: shown after enroll actions; EnableViewState="false" clears it on next load --%>
    <asp:Label ID="lblMessage" runat="server" Visible="false" EnableViewState="false" />

    <!-- ===== FILTER & SEARCH BAR ===== -->
    <div class="filter-bar">

        <!-- Search box: user must click the Search button, not auto-postback -->
        <div class="filter-group filter-search">
            <label>Search</label>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="&#128269; Search courses..."
                AutoPostBack="false" />
        </div>

        <%-- AutoPostBack="true": page reloads and re-filters as soon as user picks a category --%>
        <div class="filter-group">
            <label>Category</label>
            <asp:DropDownList ID="ddlCategory" runat="server"
                CssClass="form-control"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                <asp:ListItem Value="">All Categories</asp:ListItem>
                <asp:ListItem Value="Programming">Programming</asp:ListItem>
                <asp:ListItem Value="Web Development">Web Development</asp:ListItem>
                <asp:ListItem Value="Computer Science">Computer Science</asp:ListItem>
                <asp:ListItem Value="Mathematics">Mathematics</asp:ListItem>
                <asp:ListItem Value="Data Science">Data Science</asp:ListItem>
                <asp:ListItem Value="Design">Design</asp:ListItem>
            </asp:DropDownList>
        </div>

        <%-- AutoPostBack="true": re-queries with a different ORDER BY when sort changes --%>
        <div class="filter-group">
            <label>Sort By</label>
            <asp:DropDownList ID="ddlSort" runat="server"
                CssClass="form-control"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                <asp:ListItem Value="name_asc">Name (A-Z)</asp:ListItem>
                <asp:ListItem Value="name_desc">Name (Z-A)</asp:ListItem>
                <asp:ListItem Value="newest">Newest First</asp:ListItem>
            </asp:DropDownList>
        </div>

        <asp:Button ID="btnSearch" runat="server"
            Text="Search"
            OnClick="btnSearch_Click"
            CssClass="btn btn-primary" />
    </div>

    <!-- ===== COURSE CARDS GRID ===== -->
    <%-- Repeater used instead of GridView so we can design our own card layout in HTML --%>
    <asp:Repeater ID="rptCourses" runat="server">
        <HeaderTemplate>
            <div class="courses-grid">
        </HeaderTemplate>
        <ItemTemplate>
            <div class="course-card">
                <%-- Eval() reads the field value from the current data row --%>
                <div class='course-thumbnail <%# GetThumbClass(Eval("category").ToString()) %>'>
                    <span><%# GetCatIcon(Eval("category").ToString()) %></span>
                </div>
                <div class="course-card-body">
                    <span class='course-tag <%# GetTagClass(Eval("category").ToString()) %>'>
                        <%-- Server.HtmlEncode prevents XSS by escaping special characters --%>
                        <%# Server.HtmlEncode(Eval("category").ToString()) %>
                    </span>
                    <h3><%# Server.HtmlEncode(Eval("course_name").ToString()) %></h3>
                    <%-- truncate description to 100 characters so all cards stay the same height --%>
                    <p><%# Server.HtmlEncode(Eval("description").ToString().Length > 100
                            ? Eval("description").ToString().Substring(0, 100) + "..."
                            : Eval("description").ToString()) %></p>
                    <div class="course-meta">
                        <span>&#128218; <%# Eval("lesson_count") %> Lessons</span>
                        <span>&#128394; <%# Eval("quiz_count") %> Quizzes</span>
                    </div>
                </div>
                <div class="course-card-footer">
                    <%-- GetActionButton() returns different HTML based on login/enrollment state --%>
                    <%# GetActionButton(Eval("course_id"), Eval("is_enrolled")) %>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>

    <!-- shown by code-behind when the query returns 0 rows -->
    <asp:Panel ID="pnlNoResults" runat="server" Visible="false">
        <div class="empty-state">
            <div class="empty-icon">&#128214;</div>
            <h3>No courses found</h3>
            <p>Try adjusting your search or filters.</p>
        </div>
    </asp:Panel>

    <!-- ===== PAGINATION ===== -->
    <asp:Panel ID="pnlPagination" runat="server">
        <div class="pagination">
            <asp:Button ID="btnPrev" runat="server"
                Text="&laquo; Previous"
                OnClick="btnPrev_Click"
                CssClass="page-btn" />

            <%-- rptPages is bound to a list of page numbers in BuildPagination() --%>
            <asp:Repeater ID="rptPages" runat="server">
                <ItemTemplate>
                    <%-- active page gets "page-btn active" class, others get "page-btn" --%>
                    <asp:LinkButton ID="lbPage" runat="server"
                        Text='<%# Eval("PageNum") %>'
                        CommandArgument='<%# Eval("PageNum") %>'
                        OnCommand="lbPage_Command"
                        CssClass='<%# (int)Eval("PageNum") == CurrentPage ? "page-btn active" : "page-btn" %>' />
                </ItemTemplate>
            </asp:Repeater>

            <asp:Button ID="btnNext" runat="server"
                Text="Next &raquo;"
                OnClick="btnNext_Click"
                CssClass="page-btn" />
        </div>
    </asp:Panel>

    <%-- hidden field stores the course_id; hidden button triggers the enroll postback via JavaScript --%>
    <asp:HiddenField ID="hdnEnrollCourseId" runat="server" />
    <asp:Button ID="btnEnroll" runat="server" Style="display:none;"
        OnClick="btnEnroll_Click" />

  </div><!-- /container -->
</div>

</asp:Content>
