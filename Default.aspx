<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default"
    MasterPageFile="~/Site.master" Title="Home" %>
<%--
    Author:      Ng Ern Chi
    Description: Home / landing page (ASPX markup)
    Date:        23/5/2026
--%>

<%-- fills the <title> tag in the browser tab --%>
<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">Home</asp:Content>

<%-- main body content goes inside this block --%>
<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

    <!-- ===== HERO SECTION ===== -->
    <section class="hero">
        <div class="hero-inner">
            <div class="hero-content">
                <div class="hero-badge">&#127891; New courses added weekly</div>
                <h1>Learn Smarter,<br /><span>Grow Faster</span></h1>
                <p>
                    Master new skills through structured courses, interactive quizzes, and
                    real-time progress tracking &mdash; all in one platform built for modern learners.
                </p>
                <div class="hero-actions">
                    <%-- server-side link control; NavigateUrl sets where it goes --%>
                    <asp:HyperLink ID="hlStartLearning" runat="server"
                        NavigateUrl="CourseList.aspx"
                        CssClass="btn btn-white btn-lg"
                        style="display:inline-flex;">
                        &#9654;&nbsp; Start Learning
                    </asp:HyperLink>
                    <a href="Register.aspx" class="btn btn-outline-light btn-lg">Create Account</a>
                </div>
                <%-- these numbers are static, not from the database --%>
                <div class="hero-stats">
                    <div class="hero-stat-item">
                        <div class="hero-stat-num">6+</div>
                        <div class="hero-stat-lbl">Courses</div>
                    </div>
                    <div class="hero-stat-item">
                        <div class="hero-stat-num">50+</div>
                        <div class="hero-stat-lbl">Lessons</div>
                    </div>
                    <div class="hero-stat-item">
                        <div class="hero-stat-num">8+</div>
                        <div class="hero-stat-lbl">Quizzes</div>
                    </div>
                    <div class="hero-stat-item">
                        <div class="hero-stat-num">Free</div>
                        <div class="hero-stat-lbl">Access</div>
                    </div>
                </div>
            </div>
            <%-- decorative floating cards, no server data --%>
            <div class="hero-visual">
                <div class="hero-card-stack">
                    <div class="hero-floating-card card-1">
                        <div class="hfc-icon">&#128218;</div>
                        <div class="hfc-title">Python Basics</div>
                        <div class="hfc-sub">10 lessons &bull; Beginner</div>
                    </div>
                    <div class="hero-floating-card card-2">
                        <div class="hfc-icon">&#128200;</div>
                        <div class="hfc-title">Progress: 85%</div>
                        <div class="hfc-sub">Web Development</div>
                    </div>
                    <div class="hero-floating-card card-3">
                        <div class="hfc-icon">&#127941;</div>
                        <div class="hfc-title">Quiz Score: 92%</div>
                        <div class="hfc-sub">&#10003; Passed!</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== PLATFORM FEATURES ===== -->
    <section class="features-section">
        <div class="container">
            <div class="section-title">
                <div class="label">Why InsightLearn?</div>
                <h2>Everything You Need to Succeed</h2>
                <p>A complete learning environment with all the tools to help you achieve your goals.</p>
            </div>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">&#128218;</div>
                    <h3>Structured Courses</h3>
                    <p>Access well-organized courses with video lessons and rich written content across multiple subject areas.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">&#128396;</div>
                    <h3>Interactive Quizzes</h3>
                    <p>Test your understanding with multiple-choice assessments and receive instant, detailed feedback on your answers.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">&#128200;</div>
                    <h3>Progress Tracking</h3>
                    <p>Monitor your learning journey with completion percentages, quiz scores, and a personal performance dashboard.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">&#127775;</div>
                    <h3>Achievement Badges</h3>
                    <p>Earn rewards as you complete lessons and quizzes, keeping you motivated throughout your learning journey.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">&#128104;&#8205;&#128187;</div>
                    <h3>Expert Content</h3>
                    <p>Quality course content written by subject matter experts covering programming, design, data science, and more.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">&#128241;</div>
                    <h3>Learn Anywhere</h3>
                    <p>Fully responsive design means you can access your courses and track progress on any device, anytime.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== HOW IT WORKS ===== -->
    <section class="howit-section">
        <div class="container">
            <div class="section-title">
                <div class="label">Get Started in Minutes</div>
                <h2>How InsightLearn Works</h2>
                <p>Four simple steps to start your learning journey today.</p>
            </div>
            <div class="howit-grid">
                <div class="howit-step">
                    <div class="howit-num">1</div>
                    <h4>Create Account</h4>
                    <p>Register for free in seconds &mdash; no credit card required.</p>
                </div>
                <div class="howit-step">
                    <div class="howit-num">2</div>
                    <h4>Browse Courses</h4>
                    <p>Explore our catalogue and enroll in courses that match your goals.</p>
                </div>
                <div class="howit-step">
                    <div class="howit-num">3</div>
                    <h4>Watch &amp; Learn</h4>
                    <p>Work through video lessons and reading material at your own pace.</p>
                </div>
                <div class="howit-step">
                    <div class="howit-num">4</div>
                    <h4>Take Quizzes</h4>
                    <p>Test your knowledge and track your performance over time.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== CTA BANNER ===== -->
    <section class="cta-banner">
        <div class="cta-inner">
            <h2>Ready to Start Learning?</h2>
            <p>
                Join students already levelling up their skills on InsightLearn.
                Create your free account and start learning today.
            </p>
            <div class="cta-actions">
                <a href="Register.aspx" class="btn btn-white btn-lg">Create Free Account</a>
                <a href="CourseList.aspx" class="btn btn-outline-light btn-lg">Browse Courses</a>
            </div>
        </div>
    </section>

</asp:Content>
