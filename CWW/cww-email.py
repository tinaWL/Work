import csv, smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from jinja2 import Environment

sender_email = "tinabuztech@gmail.com"
receiver_email = "tinabuztech@gmail.com"
password = input("Type your password and press enter:")


message["From"] = sender_email
message["To"] = receiver_email


TEMPLATE = """\
<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <meta content="telephone=no" name="format-detection" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <meta content="IE=edge" http-equiv="X-UA-Compatible" />
    <link href="https://fonts.googleapis.com/css?family=Muli:300,300i,400,400i" rel="stylesheet" type="text/css" />
    <title>Williamsburg
      Learning</title>
  </head><body>
  <table align="center" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 100%;">
  <tbody>
    <tr>
      <td align="center" style="border-collapse: collapse; mso-line-height-rule: exactly;" valign="top">
        <table align="center" border="0" cellpadding="0" cellspacing="0" class="em_main_table" style="table-layout: fixed; border-collapse: collapse;
        width: 820px;">
          <tbody>
            <tr>
              <td align="center" style="border-collapse: collapse;
              mso-line-height-rule: exactly;" valign="top">
                <a class="inf-track-no" href="#" style="text-decoration: none; border-collapse: collapse; mso-line-height-rule:
                exactly;" target="_blank"><img alt="WILLIAMSBURG LEARNING" border="0" class="em_full_img" height="270" src="https://www.williamsburgacademy.org/wp-content/uploads/sites/3/2016/12/wl_banner.jpg" style="display: block; font-family: Arial, sans-serif; font-size: 20px;
                  line-height: 270px; color: #000000; max-width: 820px; border: 0
                !important; outline: none !important;" width="820" /></a>
            </td>
            </tr><tr>
            <td align="center" style="border-collapse: collapse;
            mso-line-height-rule: exactly;" valign="top">
              <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width:
              100%;">
                <tbody>
                  <tr>
                    <td class="em_spacer" style="border-collapse: collapse;
                    mso-line-height-rule: exactly;" width="42">
                      &nbsp;
                    </td>
                    <td align="center" style="border-collapse: collapse; mso-line-height-rule: exactly;" valign="top">
                      <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 742px; height: 519px;">
                        <tbody>
                          <tr>
                            <td align="left" class="em_font1" style="border-collapse: collapse;
                            mso-line-height-rule: exactly; font-family: 'Muli', Arial,
                            sans-serif; font-size: 18px; line-height: 28px;
                            color: #000000;" valign="top">
                              <p>
                                <strong>Dear {{ student }} and
                                  Parent,</strong>
                              </p>
                              <p>
                                Welcome to the Connect with the World Humanities
                                Project! I am excited to share with you your Connect with the World Foreign
                                Friend&rsquo;s name and email address. (Some of you may have two Foreign
                                Friends, because there was so much excitement by our Foreign Friends to
                                participate!)
                              </p>
                              <p dir="ltr">
                                {{ buddies }}
                              </p>
                              <p dir="ltr">
                                You can now send
                                your first email and introduction video!&nbsp;
                              </p>
                              <p>
                                &nbsp;
                              </p>
                              <p dir="ltr">
                                Mrs. Mitchell
                              </p>
                              <p dir="ltr">
                                SS/Humanities Program
                                Leader
                              </p>
                              <p>
                                &nbsp;
                              </p>
                            </td>
                            </tr><tr>
                              <td align="center" style="border-collapse:
                              collapse; mso-line-height-rule: exactly;" valign="top">
                                <table align="center" bgcolor="#000000" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 100%;">
                                  <tbody>
                                    <tr>
                                      <td class="em_spacer" style="border-collapse: collapse; mso-line-height-rule:
                                      exactly;" width="23">
                                        &nbsp;
                                      </td>
                                      <td align="center" style="border-collapse:
                                      collapse; mso-line-height-rule: exactly;" valign="top">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;
                                        width: 100%;">
                                          <tbody>
                                            <tr>
                                              <td height="14" style="font-size: 1px; line-height:
                                              1px; border-collapse: collapse; mso-line-height-rule:
                                              exactly;">
                                                &nbsp;
                                              </td>
                                            </tr><tr>
                                            <td align="center" style="border-collapse:
                                            collapse; mso-line-height-rule: exactly;" valign="top">
                                              <a class="inf-track-no" href="#" style="text-decoration: none; border-collapse: collapse;
                                              mso-line-height-rule: exactly;" target="_blank"><img alt="WILLIAMSBURG
                                                LEARNING" border="0" height="81" src="https://www.williamsburgacademy.org/wp-content/uploads/sites/3/2016/12/wl_footer_logo.png" style="display: block; font-family: Arial, sans-serif; font-size: 15px;
                                              line-height: 20px; color: #ffffff; max-width: 236px; border: 0
                                              !important; outline:
                                              none
                                              !important;" width="236" /></a>
                                            </td>
                                            </tr><tr>
                                            <td class="em_hit" height="10" style="font-size: 1px; line-height: 1px; border-collapse: collapse;
                                            mso-line-height-rule: exactly;">
                                              &nbsp;
                                            </td>
                                            </tr><tr>
                                            <td align="center" class="em_font5" style="border-collapse: collapse; mso-line-height-rule:
                                            exactly; font-family: 'Muli',
                                            Arial,
                                            sans-serif; font-size:
                                            16px; line-height: 20px; color: #ffffff; font-weight: bold; text-decoration:
                                            none;" valign="top">
                                              <a class="em_font5
                                              inf-track-29007" href="http://www.williamsburglearning.com/" style="border-collapse: collapse;
                                              mso-line-height-rule: exactly; font-family: 'Muli',
                                              Arial,
                                              sans-serif;
                                              font-size: 16px; line-height: 20px; color: #ffffff; font-weight: bold;
                                              text-decoration: none;" target="_blank">www.williamsburglearning.com</a>
                                            </td>
                                            </tr><tr>
                                              <td height="5" style="font-size: 1px; line-height: 1px; border-collapse: collapse;
                                              mso-line-height-rule: exactly;">
                                                &nbsp;
                                              </td>
                                              </tr><tr>
                                              <td class="em_hit" height="8" style="font-size: 1px; line-height: 1px; border-collapse: collapse;
                                              mso-line-height-rule: exactly;">
                                                &nbsp;
                                              </td>
                                              </tr><tr>
                                              <td height="20" style="font-size: 1px; line-height: 1px; border-collapse: collapse;
                                              mso-line-height-rule: exactly;">
                                                &nbsp;
                                              </td>
                                              </tr>
                                            </tbody>
                                            </table>
                                            </td>
                                              <td class="em_spacer" style="border-collapse: collapse; mso-line-height-rule:
                                              exactly;" width="23">
                                                &nbsp;
                                              </td>
                                            </tr>
                                            </tbody>
                                            </table>
                                            </td>
                                            </tr>
                                            </tbody>
                                            </table>
                                            </td>
                                            </tr>
                                            </tbody>
                                            </table>
                                              <div class="em_hide" style="white-space: nowrap; font: 20px
                                              courier; color: #ffffff; background-color: #ffffff;">
                                                &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                                              </div>
                                            </td>
                                            </tr>
                                            </tbody>
                                            </table>
                                            </td>
                                            </tr>
                                            </tbody>
                                            </table>
                                            </body>
                                            </html>​
"""





context = ssl.create_default_context()
with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
    server.login(sender_email, password)
    with open("null-emails.csv") as file:
        reader = csv.reader(file)
        for name, buddy in reader:
            buddy.encode('utf-8')
            message = MIMEText(
                Environment().from_string(TEMPLATE).render(
                    student=name,
                    buddies=buddy
                ), "html"
            )
            server.sendmail(
                sender_email,
                receiver_email,
                message.as_string().format(student=name,buddies=buddy).encode('utf-8'),
            )
