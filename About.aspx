<%@ Page Language="C#" AutoEventWireup="true" CodeFile="About.aspx.cs" Inherits="About"
    MasterPageFile="~/Site.master" Title="About Us" %>
<%--
    Author:      Oswald Loh Kar Tzun
    Description: About us team page (ASPX markup)
    Date:        23/5/2026
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphTitle" runat="server">About Us</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphContent" runat="server">

<!-- ===== ABOUT HERO ===== -->
<section class="about-hero">
    <div class="container">
        <div class="about-hero-inner">
            <h1>About <span class="about-hero-brand">InsightLearn</span></h1>
            <p>
                InsightLearn is a full-featured e-learning platform built as a university Web Technology
                project. Our goal was to create a modern, accessible learning management system where
                students can enrol in courses, watch lessons, take quizzes, and track their progress.
            </p>
        </div>
    </div>
</section>

<!-- ===== WHAT WE BUILT ===== -->
<section class="about-pillars">
    <div class="container">
        <div class="pillars-row">
            <div class="pillar-item">
                <div class="pillar-icon">&#127891;</div>
                <div class="pillar-text">
                    <strong>Structured Courses</strong>
                    <span>Multi-lesson courses with video and written content</span>
                </div>
            </div>
            <div class="pillar-divider"></div>
            <div class="pillar-item">
                <div class="pillar-icon">&#128396;</div>
                <div class="pillar-text">
                    <strong>Interactive Quizzes</strong>
                    <span>Multiple-choice assessments with instant scoring</span>
                </div>
            </div>
            <div class="pillar-divider"></div>
            <div class="pillar-item">
                <div class="pillar-icon">&#128200;</div>
                <div class="pillar-text">
                    <strong>Progress Tracking</strong>
                    <span>Completion percentages and performance dashboard</span>
                </div>
            </div>
            <div class="pillar-divider"></div>
            <div class="pillar-item">
                <div class="pillar-icon">&#127941;</div>
                <div class="pillar-text">
                    <strong>Certificates</strong>
                    <span>Earn a certificate on completing every course</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ===== TEAM ===== -->
<section class="about-team">
    <div class="container">
        <div class="about-team-header">
            <h2>Our Team</h2>
            <p>Five students who designed and built this platform from scratch.</p>
        </div>

        <div class="team-members-row">

            <div class="team-member">
                <img src="Images/Ng%20Ern%20Chi.jpg" alt="Ng Ern Chi" class="team-photo"
                    style="object-position: center 12%;" />
                <div class="member-name">Ng Ern Chi</div>
                <div class="member-role">Course Module Engineer</div>
            </div>

            <div class="team-member">
                <img src="Images/Oswald%20Loh%20Kar%20Tzun.jpg" alt="Oswald Loh Kar Tzun" class="team-photo"
                    style="object-position: center 18%;" />
                <div class="member-name">Oswald Loh Kar Tzun</div>
                <div class="member-role">Analytics Module Engineer</div>
            </div>

            <div class="team-member">
                <img src="Images/Chan%20Kar%20Jun.jpeg" alt="Chan Kar Jun" class="team-photo"
                    style="object-position: center 45%;" />
                <div class="member-name">Chan Kar Jun</div>
                <div class="member-role">Assessment Module Engineer</div>
            </div>

            <div class="team-member">
                <img src="Images/Ian%20Lim.png" alt="Ian Lim" class="team-photo"
                    style="object-position: center 10%;" />
                <div class="member-name">Ian Lim</div>
                <div class="member-role">User Access Engineer</div>
            </div>

            <div class="team-member">
                <img src="Images/Foo%20Kim%20Chean.jpeg" alt="Foo Kim Chean" class="team-photo"
                    style="object-fit: contain; object-position: center 30%; background-color: #ffffff;" />
                <div class="member-name">Foo Kim Chean</div>
                <div class="member-role">Learning Progress Engineer</div>
            </div>

        </div>
    </div>
</section>

<!-- ===== TECH STACK ===== -->
<section class="about-tech">
    <div class="container">
        <div class="about-team-header">
            <h2>Technology Stack</h2>
        </div>
        <div class="tech-stack-grid">
            <div class="tech-item">
                <div class="tech-icon">&#128187;</div>
                <div class="tech-name">ASP.NET Web Forms</div>
                <div class="tech-desc">.NET Framework 4.7.2</div>
            </div>
            <div class="tech-item">
                <div class="tech-icon">&#128451;</div>
                <div class="tech-name">SQL Server</div>
                <div class="tech-desc">LocalDB &amp; ADO.NET</div>
            </div>
            <div class="tech-item">
                <div class="tech-icon">&#127912;</div>
                <div class="tech-name">HTML5 &amp; CSS3</div>
                <div class="tech-desc">Flexbox, Grid &amp; Variables</div>
            </div>
            <div class="tech-item">
                <div class="tech-icon">&#9889;</div>
                <div class="tech-name">JavaScript</div>
                <div class="tech-desc">Vanilla ES5 &mdash; no frameworks</div>
            </div>
        </div>
    </div>
</section>

<!-- ===== CTA ===== -->
<section class="about-cta">
    <div class="container">
        <div class="about-cta-inner">
            <h2>Ready to Start Learning?</h2>
            <p>Join InsightLearn today and take your skills to the next level.</p>
            <div class="about-cta-btns">
                <a href="Register.aspx" class="btn btn-white btn-lg">Get Started Free</a>
                <a href="CourseList.aspx" class="btn btn-outline-light btn-lg">Browse Courses</a>
            </div>
        </div>
    </div>
</section>

</asp:Content>
