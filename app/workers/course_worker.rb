require 'sidekiq'

class CourseWorker

  # sidekiq worker code

  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    careers = [Career.all[16]]
    deparments = Department.all

    careers.each do |career|
      deparments.each do |department|
        scrape_courses("4530", department.id, career.id)
      end # deparments
    end # careers
  end

  # !> mismatched indentations at 'end' with 'def' at 10

  # coursescope caesar scraper code

  SUNDAY = 2 ** 6
  MONDAY = 2 ** 5
  TUESDAY = 2 ** 4
  WEDNESDAY = 2 ** 3
  THURSDAY = 2 ** 2
  FRIDAY = 2 ** 1
  SATURDAY = 2 ** 0


  attr_accessor :agent

  LOGIN_URL = 'https://ses.ent.northwestern.edu/psp/s9prod/?cmd=login'
  COURSE_CATALOG_URL = 'https://ses.ent.northwestern.edu/psc/caesar_6/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL?Page=SSR_CLSRCH_ENTRY'

  def initialize()
    @agent = Mechanize.new
    @agent.agent.ssl_version = "SSLv3"
    # agent.agent.http.ca_file = 'cacert.pem'
    authenticate()
    doc = @agent.get(COURSE_CATALOG_URL).parser
    @icsid = doc.xpath("//*[@id='ICSID']/@value").text
    @icelementnum = doc.xpath("//*[@id='ICElementNum']/@value").text
    @icstatenum = doc.xpath("//*[@id='ICStateNum']/@value").text

    puts "initialized"
  end

  def authenticate()
    page = @agent.get(LOGIN_URL)
    login_form = page.form('login')
    login_form.set_fields(:userid => ENV['user'])
    login_form.set_fields(:pwd => ENV['pass'])
    login_form.action = 'https://ses.ent.northwestern.edu/psp/caesar/?cmd=?languageCd=ENG'
    @agent.submit(login_form, login_form.buttons.first)
    puts "authenticated"
  end

  def scrape_courses(term, department, career)
    data = get_courses({term: term, department: department, career: career})
    parse_courses(data, term) if data
  end

  # !> mismatched indentations at 'end' with 'def' at 57

  def get_courses(args = {})

    args[:url] ||= "https://ses.ent.northwestern.edu/psc/caesar_4/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL"
    args[:days] ||= MONDAY | TUESDAY | WEDNESDAY | THURSDAY | FRIDAY | SATURDAY | SUNDAY
    args[:term] ||= "4530"
    args[:career] ||= "UGRD"
    args[:institution] ||= "NWUNV"
    args[:open_only] ||= "N" # N = no, Y = yes
    args[:days_matchtype] ||= "J" # J = include any, F = exclude any, I = include only, E = exclude only
    args[:instructor_matchtype] ||= "E" # B = BEGINS, C = CONTAINS, E = EXACTLY
    args[:catalog_number_matchtype] ||= "E" # G = gte, E = equal, T = lte
    args[:start_time_matchtype] ||= "E" # GT, GE = gte, E = equal, LT, LE = lte
    args[:end_time_matchtype] ||= "E" # GT, GE = gte, E = equal, LT, LE = lte
    args[:department] ||= "" # e.g. EECS
    args[:campus] ||= "" # CH, EV, DOHA, OFF
    args[:keyword] ||= ""
    args[:start_time] ||= "" # e.g. 13:50
    args[:end_time] ||= "" # e.g. 14:50
    args[:component] ||= "" # e.g. LEC
    args[:instructor] ||= "" # e.g. riesbeck
    args[:session_code] ||= ""
    args[:catalog_number] ||= "" # e.g. 111-0
    args[:class_number] ||= "" # Can't get this to work.

    days = args[:days].to_s(2)

    ajax_headers = {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
    params = {
        "ICAction" => "CLASS_SRCH_WRK2_SSR_PB_CLASS_SRCH",
        "ICSID" => @icsid,
        "ICElementNum" => @icelementnum,
        "ICStateNum" => @icstatenum,
        "DERIVED_SSTSNAV_SSTS_MAIN_GOTO$160$" => "9999",
        "CLASS_SRCH_WRK2_INSTITUTION$41$" => args[:institution],
        "CLASS_SRCH_WRK2_STRM$52$" => args[:term],
        "SSR_CLSRCH_WRK_SUBJECT$82$$0" => args[:department],
        "SSR_CLSRCH_WRK_SSR_EXACT_MATCH1$1" => args[:catalog_number_matchtype],
        "SSR_CLSRCH_WRK_CATALOG_NBR$1" => args[:catalog_number],
        "SSR_CLSRCH_WRK_ACAD_CAREER$2" => args[:career],
        "SSR_CLSRCH_WRK_SSR_OPEN_ONLY$chk$3" => args[:open_only],
        "SSR_CLSRCH_WRK_DESCR$4" => args[:keyword],
        "SSR_CLSRCH_WRK_SSR_START_TIME_OPR$5" => args[:start_time_matchtype],
        "SSR_CLSRCH_WRK_MEETING_TIME_START$5" => args[:start_time],
        "SSR_CLSRCH_WRK_SSR_END_TIME_OPR$5" => args[:end_time_matchtype],
        "SSR_CLSRCH_WRK_MEETING_TIME_END$5" => args[:end_time],
        "SSR_CLSRCH_WRK_INCLUDE_CLASS_DAYS$6" => args[:days_matchtype],
        "SSR_CLSRCH_WRK_SUN$chk$6" => days[0] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_SUN$6" => days[0] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_MON$chk$6" => days[1] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_MON$6" => days[1] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_TUES$chk$6" => days[2] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_TUES$6" => days[2] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_WED$chk$6" => days[3] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_WED$6" => days[3] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_THURS$chk$6" => days[4] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_THURS$6" => days[4] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_FRI$chk$6" => days[5] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_FRI$6" => days[5] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_SAT$chk$6" => days[6] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_SAT$6" => days[6] == 1 ? "Y" : "N",
        "SSR_CLSRCH_WRK_SSR_EXACT_MATCH2$7" => args[:instructor_matchtype],
        "SSR_CLSRCH_WRK_LAST_NAME$7" => args[:instructor],
        "SSR_CLSRCH_WRK_CLASS_NBR$8" => args[:class_number],
        "SSR_CLSRCH_WRK_CAMPUS$9" => args[:campus],
        "SSR_CLSRCH_WRK_SSR_COMPONENT$10" => args[:component],
        "SSR_CLSRCH_WRK_SESSION_CODE$11" => args[:session_code],
        "SSR_CLSRCH_WRK_CRSE_ATTR$12" => "",
        "SSR_CLSRCH_WRK_CRSE_ATTR_VALUE$12" => "",
        "DERIVED_SSTSNAV_SSTS_MAIN_GOTO$188$" => "9999"
    }

    response = @agent.post(args['url'], params, ajax_headers)
    doc = Nokogiri::HTML(response.body)

    error = doc.search("span[id^='DERIVED_CLSMSG_ERROR_TEXT']/text()")

    if error.present?
      handle_error(error, args)
      return false
    end

    return doc

  end

  def parse_courses(doc, term)

    courses = doc.search("span[id^='DERIVED_CLSRCH_DESCR200$']/text()").to_a

    location_counter = 0
    section_counter = 0

    courses.each_with_index do |x, i|
      courses[i] = CGI.unescapeHTML(courses[i].to_s).delete!("^\u{0000}-\u{007F}")
      courses[i] =~ /(^\w+)(\s+)(\d+-\d+) - (.*)/
      department = $1
      number = $3
      title = $4
      sections = doc.search("div[id='win6div$ICField242GP$" + i.to_s + "'] > span[class='PSGRIDCOUNTER']/text()").to_s.gsub(/1.*of\s/, "").to_i
      locations = doc.search("div[id='win6divSSR_CLSRCH_MTG1$" + location_counter.to_s + "'] > table > tr").length - 1

      puts ""
      puts "#{department} #{number} #{title} has #{sections} sections"

      sections.times do |blah1|

        uniqueid_sec = doc.search("a[id='DERIVED_CLSRCH_SSR_CLASSNAME_LONG$" + section_counter.to_s + "']").text
        uniqueid_sec =~ /(\w+)-(\w+)\((\d+)\)/

        section = $1 # !> assigned but unused variable - section
        category = $2 # !> assigned but unused variable - category
        unique_id = $3 # !> assigned but unused variable - unique_id

        status = doc.search("div[id='win6divDERIVED_CLSRCH_SSR_STATUS_LONG$" + section_counter.to_s + "'] > div > img")[0]['alt']

        puts "-- #{uniqueid_sec} #{status} has #{locations} locations"

        course = Course.find_or_initialize_by(id: unique_id)
        course.update_attributes(
           title: title,
           number: number,
           section: section,
           status: status,
           category: category,
           term: Term.find_by_id(term),
           department: Department.find_by_id(department)
        )

        locations.times do |blah2|

          instructors = doc.search("span[id='MTG_INSTR$" + location_counter.to_s + "']").text
          puts doc.search("span[id='MTG_INSTR$" + location_counter.to_s + "']")

          instructor_ids = []

          instructors.split(", \n").each do |instructor|
            if instructor == "Staff"
              instructor_ids << Instructor.find_or_create_by(:first_name => "Staff", :last_name => "Staff", :category => "Unknown")
            elsif  instructor.split.length == 2
              instructor_ids << Instructor.find_or_create_by(:first_name => instructor.split[0], :last_name => instructor.split[1], :category => "Professor")
            elsif instructor.split.length == 3
              instructor_ids << Instructor.find_or_create_by(:first_name => instructor.split[0], :middle_name => instructor.split[1], :last_name => instructor.split[2], :category => "Professor")
            else
              puts "ERROR ERROR ERROR ERROR ERROR NOOOOOO"
              puts instructor
              puts "ERROR ERROR ERROR ERROR ERROR NOOOOOO"
            end
          end

          puts instructor_ids

          room = doc.search("span[id='MTG_ROOM$" + location_counter.to_s + "']").text
          dates = doc.search("span[id='MTG_TOPIC$" + location_counter.to_s + "']").text
          seats = doc.search("span[id='NW_DERIVED_SS3_AVAILABLE_SEATS$" + location_counter.to_s + "']").text
          days_time = doc.search("span[id='MTG_DAYTIME$" + location_counter.to_s + "']").text

          if (days_time != "TBA")
            days_time =~ /^(\w+) (\d\d?:\d\d(AM|PM)) - (\d\d?:\d\d(AM|PM))/
            days = $1
            start_time = $2
            end_time = $4
          else
            days = "TBA"
            start_time = "TBA"
            end_time = "TBA"
          end

          days_int = 0

          days_int += SUNDAY if days.include? ("Su")
          days_int += MONDAY if days.include? ("Mo")
          days_int += TUESDAY if days.include? ("Tu")
          days_int += WEDNESDAY if days.include? ("We")
          days_int += THURSDAY if days.include? ("Th")
          days_int += FRIDAY if days.include? ("Fr")
          days_int += SATURDAY if days.include? ("Sa")



          #puts mo + tu + we + th + fr

          #puts "-------- #{room} #{instructor} #{dates} #{seats} #{days_time}"

          location_counter += 1
        end # end locations

        section_counter += 1

      end # end sections
    end # end courses
  end

  def handle_error(error, args = {})
    error = error.to_s
    error = error.gsub 'The search returns no results that match the criteria specified.', 'No results for specified filters.'
    error = error.gsub 'Your search will exceed the maximum limit of 200 sections.  Specify additional criteria to continue.', 'Exceeds maximum limit.'

    puts "For the following filters: "
    puts args
    if (error.include? "No courses this quarter.")
      puts error
    elsif (error.include? "Exceeds maximum limit.")
      puts error.yellow
    else
      puts error.red
    end
  end

  def lastdoc
    agent.current_page().parser
  end

end

# doc.css("input[type='hidden']").map do |elm|
#   ["name", "value"].map do |k| 
#     elm.attributes[k].text
#   end
# end

if __FILE__ == $0

  puts 1 + 1
end
