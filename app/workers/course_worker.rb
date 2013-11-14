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

  # coursescope caesar scraper code

	MONDAY = 2 ** 4
	TUESDAY = 2 ** 3
	WEDNESDAY = 2 ** 2
	THURSDAY = 2 ** 1
	FRIDAY = 2 ** 0  

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
		@icelementnum = doc.xpath( "//*[@id='ICElementNum']/@value").text
		@icstatenum = doc.xpath("//*[@id='ICStateNum']/@value").text

		puts "initialized"
	end

	def authenticate()
		page = @agent.get(LOGIN_URL)
		login_form = page.form('login')
		login_form.set_fields(:userid => ENV['user'])
		login_form.set_fields(:pwd => ENV['pass'])
		login_form.action = 'https://ses.ent.northwestern.edu/psp/caesar/?cmd=?languageCd=ENG'
		page = @agent.submit(login_form, login_form.buttons.first)
		puts "authenticated"
	end

	def scrape_courses(term, department, career)
  	data = get_courses(term, department, career)
  	parse_courses(data, term) if data != false
  end

	def get_courses(term, department, career)
		url = 'https://ses.ent.northwestern.edu/psc/caesar_4/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL'
		ajax_headers = { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' }
		params = {
			"ICAction" => "CLASS_SRCH_WRK2_SSR_PB_CLASS_SRCH",
			"ICSID" => @icsid,
			"ICElementNum" => @icelementnum,
			"ICStateNum" => @icstatenum,
			"DERIVED_SSTSNAV_SSTS_MAIN_GOTO$180$" => "9999",
			"CLASS_SRCH_WRK2_INSTITUTION$41$" => "NWUNV",
			"CLASS_SRCH_WRK2_STRM$44$"=> term,
			"SSR_CLSRCH_WRK_SUBJECT$0"=> department,
			"SSR_CLSRCH_WRK_CATALOG_NBR$1" => "",
			"SSR_CLSRCH_WRK_SSR_EXACT_MATCH1$1" => "E",
			"SSR_CLSRCH_WRK_ACAD_CAREER$2" => career,
			"SSR_CLSRCH_WRK_SSR_OPEN_ONLY$chk$3" => "N",
			"DERIVED_SSTSNAV_SSTS_MAIN_GOTO$152$"=> "9999",
			"CLASS_SRCH_WRK2_INCLUDE_CLASS_DAYS"=> "J",
			"CLASS_SRCH_WRK2_MON$chk"=>"Y",
			"CLASS_SRCH_WRK2_MON"=>"Y",
			"CLASS_SRCH_WRK2_TUES$chk"=>"Y",
			"CLASS_SRCH_WRK2_TUES"=>"Y",
			"CLASS_SRCH_WRK2_WED$chk"=>"Y",
			"CLASS_SRCH_WRK2_WED"=>"Y",
			"CLASS_SRCH_WRK2_THURS$chk"=>"Y",
			"CLASS_SRCH_WRK2_THURS"=>"Y",
			"CLASS_SRCH_WRK2_FRI$chk"=>"Y",
			"CLASS_SRCH_WRK2_FRI"=>"Y",
			"CLASS_SRCH_WRK2_SAT$chk"=>"",
			"CLASS_SRCH_WRK2_SUN$chk"=>""						
		}

		response = @agent.post(url, params, ajax_headers)
		doc = Nokogiri::HTML(response.body)

		error = doc.search("span[id^='DERIVED_CLSMSG_ERROR_TEXT']/text()")

		if (error.present?)
			handle_error(error, department)
			return false
		end

		return doc

	end  
	
	def parse_courses(doc, term)

		courses = doc.search("span[id^='DERIVED_CLSRCH_DESCR200$']/text()").to_a

		locationCounter = 0
		sectionCounter = 0

		courses.each_with_index do |x,i| 
			courses[i] = CGI.unescapeHTML(courses[i].to_s).delete!("^\u{0000}-\u{007F}")
			courses[i] =~ /(^\w+)(\s+)(\d+-\d+) - (.*)/
			department = $1
      number = $3
      title = $4
			sections = doc.search("div[id='win6div$ICField242GP$" + i.to_s + "'] > span[class='PSGRIDCOUNTER']/text()").to_s.gsub(/1.*of\s/, "").to_i
			locations = doc.search("div[id='win6divSSR_CLSRCH_MTG1$" + locationCounter.to_s + "'] > table > tr")

			locLength = locations.length - 1

			puts ""
			puts "#{department} #{number} #{title} has #{sections} sections"

			sections.times do |blah1|

				uniqueid_sec = doc.search("a[id='DERIVED_CLSRCH_SSR_CLASSNAME_LONG$" + sectionCounter.to_s + "']").text
				uniqueid_sec =~ /(\w+)-(\w+)\((\d+)\)/
				
				section = $1
      	category = $2
      	unique_id = $3

      	status = doc.search("div[id='win6divDERIVED_CLSRCH_SSR_STATUS_LONG$" + sectionCounter.to_s + "'] > div > img")[0]['alt']

				puts "-- #{uniqueid_sec} #{status} has #{locLength} locations"

				course = Course.find_or_initialize_by(id: unique_id)

				# debugger

				course.update_attributes(
				   title: title,
				   number: number,
				   section: section,
				   status: status,
				   category: category,
				   term: Term.find_by_id(term),
				   department: Department.find_by_id(department)
				)

				locLength.times do |blah2|

					instructor = doc.search("span[id='MTG_INSTR$" + locationCounter.to_s + "']").text
					room = doc.search("span[id='MTG_ROOM$" + locationCounter.to_s + "']").text
					dates = doc.search("span[id='MTG_TOPIC$" + locationCounter.to_s + "']").text
					seats = doc.search("span[id='NW_DERIVED_SS3_AVAILABLE_SEATS$" + locationCounter.to_s + "']").text
	      	days_time = doc.search("span[id='MTG_DAYTIME$" + locationCounter.to_s + "']").text

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

		  		mo = days.include? ("Mo")
		  		tu = days.include? ("Tu")
		      we = days.include? ("We")
		      th = days.include? ("Th")
		      fr = days.include? ("Fr")

					puts "-------- #{room} #{instructor} #{dates} #{seats} #{days_time}"
				
					locationCounter += 1
				end # end locations
				
				sectionCounter += 1

			end # end sections
		end # end courses
	end

	def handle_error(error, department)
		error = error.to_s
		error = error.gsub("The search returns no results that match the criteria specified.", "No courses this quarter.")
		error = error.gsub("Your search will exceed the maximum limit of 200 sections.  Specify additional criteria to continue.", "Exceeds maximum limit.")
		# error_counter+=1
		# print "[" + error_counter.to_s + "] " + subject + ": "
		
		print department + ": "
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