<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Settings.aspx.cs" Inherits="Settings"
    MasterPageFile="~/Site.master" Title="Account Settings" %>
<%--
    Author:      Ian Lim
    Description: Account settings page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Account Settings</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<!-- Page Header -->
<div class="settings-hero">
    <div class="container">
        <div class="settings-hero-inner">
            <div class="settings-avatar">
                <asp:Literal ID="litAvatarInitial" runat="server">?</asp:Literal>
            </div>
            <div>
                <h1><asp:Literal ID="litHeaderName" runat="server">Account Settings</asp:Literal></h1>
                <p><asp:Literal ID="litHeaderEmail" runat="server" /></p>
            </div>
        </div>
    </div>
</div>

<!-- Settings Cards -->
<div class="settings-page">
  <div class="container">
    <div class="settings-grid">

      <!-- ===== Profile Card ===== -->
      <div class="card settings-card">
          <div class="card-header">
              <h3>&#128100; Profile</h3>
          </div>
          <div class="card-body">
              <asp:Label ID="lblProfileMsg" runat="server" Visible="false"
                  EnableViewState="false"
                  style="display:block; margin-bottom:16px;" />

              <div class="form-group">
                  <label>Email Address</label>
                  <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                      ReadOnly="true" style="background:#F8FAFC; color:var(--text-light); cursor:not-allowed;" />
                  <span class="settings-hint">Email cannot be changed. It is used to log in.</span>
              </div>

              <div class="form-group">
                  <label>Display Name *</label>
                  <asp:TextBox ID="txtDisplayName" runat="server" CssClass="form-control"
                      MaxLength="100" placeholder="Your full name" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDisplayName"
                      ValidationGroup="ProfileVG" CssClass="field-validator"
                      ErrorMessage="Display name is required." Display="Dynamic">Display name is required.</asp:RequiredFieldValidator>
              </div>

              <asp:Button ID="btnSaveName" runat="server" Text="Save Changes"
                  OnClick="btnSaveName_Click"
                  CssClass="btn btn-primary"
                  ValidationGroup="ProfileVG" />
          </div>
      </div>

      <!-- ===== Change Password Card ===== -->
      <div class="card settings-card">
          <div class="card-header">
              <h3>&#128274; Change Password</h3>
          </div>
          <div class="card-body">
              <asp:Label ID="lblPasswordMsg" runat="server" Visible="false"
                  EnableViewState="false"
                  style="display:block; margin-bottom:16px;" />

              <div class="form-group">
                  <label>Current Password *</label>
                  <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control"
                      TextMode="Password" MaxLength="200" placeholder="Enter current password" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCurrentPassword"
                      ValidationGroup="PasswordVG" CssClass="field-validator"
                      ErrorMessage="Current password is required." Display="Dynamic">Current password is required.</asp:RequiredFieldValidator>
              </div>

              <div class="form-group">
                  <label>New Password *</label>
                  <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control"
                      TextMode="Password" MaxLength="200" placeholder="At least 6 characters" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                      ValidationGroup="PasswordVG" CssClass="field-validator"
                      ErrorMessage="New password is required." Display="Dynamic">New password is required.</asp:RequiredFieldValidator>
              </div>

              <div class="form-group">
                  <label>Confirm New Password *</label>
                  <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control"
                      TextMode="Password" MaxLength="200" placeholder="Repeat new password" />
                  <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirmPassword"
                      ValidationGroup="PasswordVG" CssClass="field-validator"
                      ErrorMessage="Please confirm your new password." Display="Dynamic">Please confirm your new password.</asp:RequiredFieldValidator>
                  <asp:CompareValidator runat="server"
                      ControlToValidate="txtConfirmPassword"
                      ControlToCompare="txtNewPassword"
                      ValidationGroup="PasswordVG" CssClass="field-validator"
                      ErrorMessage="Passwords do not match." Display="Dynamic">Passwords do not match.</asp:CompareValidator>
              </div>

              <asp:Button ID="btnChangePassword" runat="server" Text="Change Password"
                  OnClick="btnChangePassword_Click"
                  CssClass="btn btn-primary"
                  ValidationGroup="PasswordVG" />
          </div>
      </div>

    </div><!-- /settings-grid -->
  </div><!-- /container -->
</div><!-- /settings-page -->

</asp:Content>
