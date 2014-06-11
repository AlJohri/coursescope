require 'sidekiq'

class CourseWorker

  # sidekiq worker code

  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    careers = [Career.all[16]]
    deparments = Department.all # Department.all # [Department.all[49]] 

    careers.each do |career|
      deparments.each do |department|
        scrape_courses("4560", department.id, career.id)
      end # deparments
    end # careers
  end

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
    puts data
    parse_courses(data, term) if data
  end

  def get_courses(args = {})

    args[:url] ||= "https://ses.ent.northwestern.edu/psc/caesar_4/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL"
    args[:days] ||= SUNDAY | MONDAY | TUESDAY | WEDNESDAY | THURSDAY | FRIDAY | SATURDAY
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
        "ICAction" => 'CLASS_SRCH_WRK2_SSR_PB_CLASS_SRCH',
        "ICSID" => @icsid,
        "ICElementNum" => @icelementnum,
        "ICStateNum" => @icstatenum,
        "DERIVED_SSTSNAV_SSTS_MAIN_GOTO$162$" => '9999',
        "CLASS_SRCH_WRK2_INSTITUTION$41$" => args[:institution],
        "CLASS_SRCH_WRK2_STRM$53$" => args[:term],
        "SSR_CLSRCH_WRK_SUBJECT_SRCH$0" => args[:department],
        "SSR_CLSRCH_WRK_SSR_EXACT_MATCH1$1" => 'C', # args[:catalog_number_matchtype],
        "SSR_CLSRCH_WRK_CATALOG_NBR$1" => args[:catalog_number],
        "SSR_CLSRCH_WRK_ACAD_CAREER$2" => args[:career],
        "SSR_CLSRCH_WRK_SSR_OPEN_ONLY$chk$3" => args[:open_only],
        # "SSR_CLSRCH_WRK_DESCR$4" => args[:keyword],
        # "SSR_CLSRCH_WRK_SSR_START_TIME_OPR$5" => args[:start_time_matchtype],
        # "SSR_CLSRCH_WRK_MEETING_TIME_START$5" => args[:start_time],
        # "SSR_CLSRCH_WRK_SSR_END_TIME_OPR$5" => args[:end_time_matchtype],
        # "SSR_CLSRCH_WRK_MEETING_TIME_END$5" => args[:end_time],
        # "SSR_CLSRCH_WRK_INCLUDE_CLASS_DAYS$6" => args[:days_matchtype],
        # "SSR_CLSRCH_WRK_SUN$chk$6" => days[0] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_SUN$6" => days[0] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_MON$chk$6" => days[1] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_MON$6" => days[1] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_TUES$chk$6" => days[2] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_TUES$6" => days[2] == 1 ? 'N' : 'N',
        # "SSR_CLSRCH_WRK_WED$chk$6" => days[3] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_WED$6" => days[3] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_THURS$chk$6" => days[4] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_THURS$6" => days[4] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_FRI$chk$6" => days[5] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_FRI$6" => days[5] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_SAT$chk$6" => days[6] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_SAT$6" => days[6] == 1 ? 'Y' : 'N',
        # "SSR_CLSRCH_WRK_SSR_EXACT_MATCH2$7" => args[:instructor_matchtype],
        # "SSR_CLSRCH_WRK_LAST_NAME$7" => args[:instructor],
        # "SSR_CLSRCH_WRK_CLASS_NBR$8" => args[:class_number],
        # "SSR_CLSRCH_WRK_CAMPUS$9" => args[:campus],
        # "SSR_CLSRCH_WRK_SSR_COMPONENT$10" => args[:component],
        # "SSR_CLSRCH_WRK_SESSION_CODE$11" => args[:session_code],
        # "SSR_CLSRCH_WRK_CRSE_ATTR$12" => "",
        # "SSR_CLSRCH_WRK_CRSE_ATTR_VALUE$12" => "",
        "DERIVED_SSTSNAV_SSTS_MAIN_GOTO$190$" => '9999'
    }

    response = @agent.post(args['url'], params, ajax_headers)
    doc = Nokogiri::HTML(response.body)

    error = doc.search("span[id^='DERIVED_CLSMSG_ERROR_TEXT']/text()")

    if error.present?
      handle_error(error, params)
      return false
    end

    return doc

  end

  def parse_courses(doc, term)

    courses = doc.search("div[id^='win6divSSR_CLSRSLT_WRK_GROUPBOX2GP$']/text()").to_a

    location_counter = 0
    section_counter = 0

    courses.each_with_index do |x, i|
      courses[i] = CGI.unescapeHTML(courses[i].to_s).delete!("^\u{0000}-\u{007F}")
      courses[i] =~ /(^\w+)(\s+)(\d+-\d+) - (.*)/
      department = $1
      number = $3
      title = $4
      sections = doc.search("div[id='win6div$ICField99$" + i.to_s + "'] > table > tr > td > table > tr").length / 2

      puts ""
      puts "#{department} #{number} #{title} has #{sections} sections"

      sections.times do |blah1|

        unique_id = doc.search("a[id='MTG_CLASS_NBR$" + section_counter.to_s + "']").text
        sec_category = doc.search("a[id='MTG_CLASSNAME$" + section_counter.to_s + "']").text
        sec_category =~ /(\w+)-(\w+)/

        section = $1
        category = $2

        status = doc.search("div[id='win6divDERIVED_CLSRCH_SSR_STATUS_LONG$" + section_counter.to_s + "'] > div > img")[0]['alt']

        locations = doc.search("div[id='win6divSSR_CLSRCH_MTG1$" + section_counter.to_s + "'] > table > tr").length - 1

        puts "-- #{unique_id} #{section} #{category} #{status} has #{locations} locations"

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

          instructor_ids = []

          # Please note this does not account for roman numerals after names
          # example: Willie Jones III (currently ID 744)
          # also confirm this is working for R P Chang (currently ID 840)
          # Suzan van der Lee ERROR ERROR!! EARTH 399-0
          # Ronald Ray Braeutigam ERROR ERROR (not sure why??) ECON 310-1
          # Susan Caplan Oloroso, # CRDV 301-0
          # Seth Magletymire, # ENVR_POL 390-0
          instructors.split(", \n").each do |instructor|
            if instructor == "Staff"
              instr = Instructor.find_or_initialize_by(:first_name => "Staff", :last_name => "Staff", :category => "Unknown")
              instr.save
              instructor_ids << instr
            elsif  instructor.split.length == 2
              instr = Instructor.find_or_initialize_by(:first_name => instructor.split[0], :last_name => instructor.split[1], :category => "Professor")
              instr.save
              instructor_ids << instr
            elsif instructor.split.length == 3
              instr = Instructor.find_or_initialize_by(:first_name => instructor.split[0], :middle_name => instructor.split[1], :last_name => instructor.split[2], :category => "Professor")
              instr.save
              instructor_ids << instr
            else
              puts 'ERROR ERROR ERROR ERROR ERROR NOOOOOO'
              puts instructor
              puts 'ERROR ERROR ERROR ERROR ERROR NOOOOOO'
            end
          end

          room = doc.search("span[id='MTG_ROOM$" + location_counter.to_s + "']").text
          dates = doc.search("span[id='MTG_TOPIC$" + location_counter.to_s + "']").text
          seats = doc.search("span[id='NW_DERIVED_SS3_AVAILABLE_SEATS$" + location_counter.to_s + "']").text
          days_time = doc.search("span[id='MTG_DAYTIME$" + location_counter.to_s + "']").text

          classroom = Classroom.find_or_initialize_by(:title => room)
          classroom.save

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

          start_time = start_time == "TBA" ? nil : TimeOfDay.parse(start_time)
          end_time = end_time == "TBA" ? nil : TimeOfDay.parse(end_time)

          #Does not support classes with exact ID meeting twice in same day...
          classtime = Classtime.find_or_initialize_by(:course_id => unique_id, :classroom_id => Classroom.find_by_title(room).id, :days =>days_int ) do |c|
            c.start_time = start_time
            c.end_time = end_time
          end
          classtime.save

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
