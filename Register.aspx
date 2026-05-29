<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Register"
    MasterPageFile="~/Site.master" Title="Register" %>
<%--
    Author:      Ian Lim
    Description: User registration page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Create Account</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

    <div class="auth-page">
        <div class="auth-card" style="max-width:440px;">

            <h2>Create Account</h2>
            <p class="auth-subtitle">Join InsightLearn and start your learning journey.</p>

            <!-- Success or error messages -->
            <asp:Label ID="lblMessage" runat="server"
                Visible="false" EnableViewState="false" />

            <!-- Validation summary -->
            <asp:ValidationSummary ID="vsRegister" runat="server"
                CssClass="validation-summary"
                HeaderText="Please fix the following:"
                DisplayMode="BulletList"
                ShowSummary="true"
                ValidationGroup="RegisterGroup" />

            <!-- Full Name -->
            <div class="form-group">
                <label for="txtName">Full Name</label>
                <asp:TextBox ID="txtName" runat="server"
                    CssClass="form-control"
                    placeholder="Enter your full name"
                    MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server"
                    ControlToValidate="txtName"
                    ErrorMessage="Full name is required."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Name is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revName" runat="server"
                    ControlToValidate="txtName"
                    ValidationExpression="^[a-zA-Z\s'-]{2,100}$"
                    ErrorMessage="Name must be 2-100 letters only."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Name should contain only letters (2–100 chars).</asp:RegularExpressionValidator>
            </div>

            <!-- Email -->
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
                    ValidationGroup="RegisterGroup">&#9888; Email is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Invalid email format.</asp:RegularExpressionValidator>
            </div>

            <!-- Password -->
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
                    ValidationGroup="RegisterGroup">&#9888; Password is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ValidationExpression="^.{6,}$"
                    ErrorMessage="Password must be at least 6 characters."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Password must be at least 6 characters.</asp:RegularExpressionValidator>
                <span class="form-hint">Minimum 6 characters</span>
            </div>

            <!-- Confirm Password -->
            <div class="form-group">
                <label for="txtConfirmPassword">Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    placeholder="Confirm your password"
                    MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ErrorMessage="Please confirm your password."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Please confirm your password.</asp:RequiredFieldValidator>
                <asp:CompareValidator ID="cvPassword" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtPassword"
                    ErrorMessage="Passwords do not match."
                    Display="Dynamic"
                    CssClass="field-validator"
                    ValidationGroup="RegisterGroup">&#9888; Passwords do not match.</asp:CompareValidator>
            </div>

            <!-- Submit button -->
            <asp:Button ID="btnRegister" runat="server"
                Text="Create Account"
                OnClick="btnRegister_Click"
                CssClass="btn btn-primary btn-block"
                ValidationGroup="RegisterGroup" />

            <!-- Login link -->
            <div class="auth-divider">
                Already have an account? <a href="Login.aspx">Login</a>
            </div>

        </div>
    </div>

</asp:Content>
