# frozen_string_literal: true

require 'bcrypt'
require 'sequel'

DB = Sequel.sqlite('./bin/db/data.db')

def reset_database!
  DB.drop_table? :user
  DB.drop_table? :user_classes
  DB.drop_table? :alert
  DB.drop_table? :post
  DB.drop_table? :reset_password
  DB.drop_table? :images
  DB.drop_table? :classes
  DB.drop_table? :policy

  DB.create_table! :user do
    Integer :id, primary_key: true
    String :name
    String :email, unique: true
    String :encrypted_password
    Integer :admin
  end

  DB.create_table! :policy do
    Integer :id, primary_key: true
    String :title
    String :body
  end

  DB.create_table! :user_classes do
    Integer :user_id
    Integer :class_id
    Integer :admin
  end

  DB.create_table! :classes do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    String :name, null: false
    String :description
    String :identifier, null: false
    String :img_path, null: true
  end

  DB.create_table! :alert do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    Integer :valid_until, null: true
    Integer :valid, null: true
    String :level, null: true
    String :message, null: true
    Integer :read_more, null: true
    String :read_more_link
  end

  DB.create_table! :post do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    String :message, null: true
    Integer :author_id, null: false
    Integer :time_stamp, null: false
    String :img_path, null: false
    String :img_name, null: false
    Integer :class_id, null: false
  end

  DB.create_table! :reset_password do
    Integer :user_id, unique: true
    String :identifier, unique: true
  end

  puts 'Seeder ran'
  puts 'Created tables'
end

def insert_data
  dataset = DB[:user]
  dataset.insert(name: 'John', email: 'john.example@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 1)
  dataset.insert(name: 'David', email: 'david.ek@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Gustav', email: 'gustav@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Admin', email: 'admin@admin', encrypted_password: BCrypt::Password.create('admin'), admin: 1)

  dataset = DB[:policy]
  dataset.insert(title: 'Privacy Policy', body: '<p>We value your data and therefore we do our utmost to store it securely.<br>
    We only store the essential personal data required for our service to function as intended. 
    That means we store the email address associated with your account so that we can come in to contact with you if required and so that you can access your account. 
    We store your name as each post is associated with an account. Your password is stored securely in our database using a hashing algorithm.</p>
    <p>Other data received by us is stored with user integrity and privacy in mind.</p>
    <p>If there are additional questions as too how we store your data do not hesitate to contact us.</p>', id: 1)
  dataset.insert(title: 'Cookie Policy', body: '
    <p>To give you as the visitor the best possible experience on our website, we utilize cookies. Cookies are used so that we can save your interactions and choices made on the website. 
    <br>In some instances third-parties might place cookies on your device to track statistics of user interactions.</p>
    <p>You can change the settings on your device to avoid us and third-parties from placing cookies on your device. Such settings would cause some functions on our website do not work.<p>
    <h1 class="title is-4">What are cookies?</h4>
    <p>A cookie is a small amount of data with a uniquely identifiable label. The data is sent from our servers to your device where the browser saves it to its memory so that the website can recognize your device.</p>
    <p>All websites can place cookies on your device if your browser settings allow for it. For this information not to be abused, websites can only read data from cookies that they placed on your device.</p>
    <p>There are two types of cookies, permanent and temporary. Permanent cookies are stored in a file on your device during a longer time frame. Temporary cookies are temporarily placed on your device when visiting a website but disappear after closing down the page, meaning they are not permanently stored on your device. Most companies use cookies on their webpages to improve user experience. And the use of cookies can not damage your files or increase the risks of malware on your device</p>
    <p>As a user you can change the settings to allow the use of cookies automatically in your browser or if you want to be asked before they are stored or if you do not agree to any cookies being placed on your device.</p>
    <p>Our cookies are used to improve the user experience, with interactive messages, the ability to login and use the webpages intended functions.<br>If you choose to deactivate cookies we can not provide our services to you, as cookies are required for our site to function properly.</p>
    <br>
    <p>More information about cookies are available at <a href="https://www.allaboutcookies.org/cookies/">www.allaboutcookies.org</a></p>
    <br>
    <p>All browsers are different. To find information on how to change the settings for cookies look for information in the help function of your browser. You can also manually erase all cookies from your device. This can be done through the browsers settings.</p>', id: 2)
  dataset.insert(title: 'Terms and Conditions', body: 
    %{<p>Welcome to Memory Archive!</p>
    <p>These terms and conditions outline the rules and regulations for the use of Memory Archive's Website.</p>
    <p>By accessing this website we assume you accept these terms and conditions. Do not continue to use Memory Archive if you do not agree to take all of the terms and conditions stated on this page.</p>
    <p>The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: "Client", "You" and "Your" refers to you, the person log on this website and compliant to the Company’s terms and conditions. "The Company", "Ourselves", "We", "Our" and "Us", refers to our Company. "Party", "Parties", or "Us", refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client’s needs in respect of provision of the Company’s stated services, in accordance with and subject to, prevailing law of Netherlands. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.</p>
    <h1 class="title is-4"><strong>Cookies</strong></h1>
    
    <p>We employ the use of cookies. By accessing Memory Archive, you agreed to use cookies in agreement with the Memory Archive's <a href="/privacy_policy">Privacy Policy</a> and <a href="/cookie_policy">Cookie Policy</a>.</p>
    <p>Most interactive websites use cookies to let us retrieve the user’s details for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier for people visiting our website. Some of our affiliate/advertising partners may also use cookies.</p>
    <h1 class="title is-4"><strong>License</strong></h1>
    <p>Unless otherwise stated, Memory Archive and/or its licensors own the intellectual property rights for all material on Memory Archive. All intellectual property rights are reserved. You may access this from Memory Archive for your own personal use subjected to restrictions set in these terms and conditions.</p>
    <p>You must not:</p>
    <ul>
        <li>Republish material from Memory Archive</li>
        <li>Sell, rent or sub-license material from Memory Archive</li>
        <li>Reproduce, duplicate or copy material from Memory Archive</li>
        <li>Redistribute content from Memory Archive</li>
    </ul>
    <p>This Agreement shall begin on the date hereof.</p>
    <p>Parts of this website offer an opportunity for users to post and exchange opinions and information in certain areas of the website. Memory Archive does not filter, edit, publish or review Comments prior to their presence on the website. Comments do not reflect the views and opinions of Memory Archive,its agents and/or affiliates. Comments reflect the views and opinions of the person who post their views and opinions. To the extent permitted by applicable laws, Memory Archive shall not be liable for the Comments or for any liability, damages or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this website.</p>
    <p>Memory Archive reserves the right to monitor all Comments and to remove any Comments which can be considered inappropriate, offensive or causes breach of these Terms and Conditions.</p>
    <p>You warrant and represent that:</p>
    <ul>
        <li>You are entitled to post the Comments on our website and have all necessary licenses and consents to do so;</li>
        <li>The Comments do not invade any intellectual property right, including without limitation copyright, patent or trademark of any third party;</li>
        <li>The Comments do not contain any defamatory, libelous, offensive, indecent or otherwise unlawful material which is an invasion of privacy</li>
        <li>The Comments will not be used to solicit or promote business or custom or present commercial activities or unlawful activity.</li>
    </ul>
    <p>You hereby grant Memory Archive a non-exclusive license to use, reproduce, edit and authorize others to use, reproduce and edit any of your Comments in any and all forms, formats or media.</p>
    <h1 class="title is-4"><strong>Hyperlinking to our Content</strong></h1>
    <p>The following organizations may link to our Website without prior written approval:</p>
    <ul>
        <li>Government agencies;</li>
        <li>Search engines;</li>
        <li>News organizations;</li>
        <li>Online directory distributors may link to our Website in the same manner as they hyperlink to the Websites of other listed businesses; and</li>
        <li>System wide Accredited Businesses except soliciting non-profit organizations, charity shopping malls, and charity fundraising groups which may not hyperlink to our Web site.</li>
    </ul>
    <p>These organizations may link to our home page, to publications or to other Website information so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products and/or services; and (c) fits within the context of the linking party’s site.</p>
    <p>We may consider and approve other link requests from the following types of organizations:</p>
    <ul>
        <li>commonly-known consumer and/or business information sources;</li>
        <li>dot.com community sites;</li>
        <li>associations or other groups representing charities;</li>
        <li>online directory distributors;</li>
        <li>internet portals;</li>
        <li>accounting, law and consulting firms; and</li>
        <li>educational institutions and trade associations.</li>
    </ul>
    <p>We will approve link requests from these organizations if we decide that: (a) the link would not make us look unfavorably to ourselves or to our accredited businesses; (b) the organization does not have any negative records with us; (c) the benefit to us from the visibility of the hyperlink compensates the absence of Memory Archive; and (d) the link is in the context of general resource information.</p>
    <p>These organizations may link to our home page so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products or services; and (c) fits within the context of the linking party’s site.</p>
    <p>If you are one of the organizations listed in paragraph 2 above and are interested in linking to our website, you must inform us by sending an e-mail to Memory Archive. Please include your name, your organization name, contact information as well as the URL of your site, a list of any URLs from which you intend to link to our Website, and a list of the URLs on our site to which you would like to link. Wait 2-3 weeks for a response.</p>
    <p>Approved organizations may hyperlink to our Website as follows:</p>
    <ul>
        <li>By use of our corporate name; or</li>
        <li>By use of the uniform resource locator being linked to; or</li>
        <li>By use of any other description of our Website being linked to that makes sense within the context and format of content on the linking party’s site.</li>
    </ul>
    <p>No use of Memory Archive's logo or other artwork will be allowed for linking absent a trademark license agreement.</p>
    <h1 class="title is-4"><strong>iFrames</strong></h1>
    <p>Without prior approval and written permission, you may not create frames around our Webpages that alter in any way the visual presentation or appearance of our Website.</p>
    <h1 class="title is-4"><strong>Content Liability</strong></h1>
    <p>We shall not be hold responsible for any content that appears on your Website. You agree to protect and defend us against all claims that is rising on your Website. No link(s) should appear on any Website that may be interpreted as libelous, obscene or criminal, or which infringes, otherwise violates, or advocates the infringement or other violation of, any third party rights.</p>
    <h1 class="title is-4"><strong>Your Privacy</strong></h1>
    <p>Please see <a href="/privacy_policy">Privacy Policy</a></p>
    <h1 class="title is-4"><strong>Reservation of Rights</strong></h1>
    <p>We reserve the right to request that you remove all links or any particular link to our Website. You approve to immediately remove all links to our Website upon request. We also reserve the right to amen these terms and conditions and it’s linking policy at any time. By continuously linking to our Website, you agree to be bound to and follow these linking terms and conditions.</p>
    <h1 class="title is-4"><strong>Removal of links from our website</strong></h1>
    <p>If you find any link on our Website that is offensive for any reason, you are free to contact and inform us any moment. We will consider requests to remove links but we are not obligated to or so or to respond to you directly.</p>
    <p>We do not ensure that the information on this website is correct, we do not warrant its completeness or accuracy; nor do we promise to ensure that the website remains available or that the material on the website is kept up to date.</p>
    <h1 class="title is-4"><strong>Disclaimer</strong></h1>
    <p>To the maximum extent permitted by applicable law, we exclude all representations, warranties and conditions relating to our website and the use of this website. Nothing in this disclaimer will:</p>
    <ul>
        <li>limit or exclude our or your liability for death or personal injury;</li>
        <li>limit or exclude our or your liability for fraud or fraudulent misrepresentation;</li>
        <li>limit any of our or your liabilities in any way that is not permitted under applicable law; or</li>
        <li>exclude any of our or your liabilities that may not be excluded under applicable law.</li>
    </ul>
    <p>The limitations and prohibitions of liability set in this Section and elsewhere in this disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising under the disclaimer, including liabilities arising in contract, in tort and for breach of statutory duty.</p>
    <p>As long as the website and the information and services on the website are provided free of charge, we will not be liable for any loss or damage of any nature.</p>}, id:3)

  puts 'Inserted data'
end

reset_database!
insert_data
