<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login"
    MasterPageFile="~/Site.master" Title="Login" %>
<%--
    Author:      Ian Lim
    Description: Login page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Login</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

    <div class="auth-page">
        <div class="auth-card">

            <h2>Login</h2>
            <p class="auth-subtitle">Welcome back! Please enter your credentials.</p>

            <!-- Error message shown on invalid login -->
            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger"
                Visible="false" EnableViewState="false" />

            <!-- Validation Summary -->
            <asp:ValidationSummary ID="vsLogin" runat="server"
                CssClass="validation-summary"
                HeaderText="Please fix the following errors:"
                DisplayMode="BulletList"
                ShowMessageBox="false"
                ShowSummary="true"
                ValidationGroup="LoginGroup" />

            <!-- Email Field -->
            <div class="form-group">
                <label for="txtEmail">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server"
                    TextMode="Email"
                    CssClass="form-control"
                    placeholder="Enter your email"
                    MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Email address is required."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="LoginGroup">&#9888; Email is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="LoginGroup">&#9888; Invalid email format.</asp:RegularExpressionValidator>
            </div>

            <!-- Password Field -->
            <div class="form-group">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    placeholder="Enter your password"
                    MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Password is required."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="LoginGroup">&#9888; Password is required.</asp:RequiredFieldValidator>
            </div>

            <!-- Login Button -->
            <asp:Button ID="btnLogin" runat="server"
                Text="Login"
                OnClick="btnLogin_Click"
                CssClass="btn btn-primary btn-block"
                ValidationGroup="LoginGroup" />

            <!-- Register link -->
            <div class="auth-divider">
                Don't have an account? <a href="Register.aspx">Register</a>
            </div>

        </div>
    </div>

</asp:Content>
