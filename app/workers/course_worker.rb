class CourseWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	attr_accessor :agent

	def initialize()
		@agent = Mechanize.new
		@agent.agent.ssl_version = "SSLv3"
		# agent.agent.http.ca_file = 'cacert.pem'

		authenticate()
		set_post_parameters()
		puts "initialized"
	end

	def perform()
  	careers = ["UGRD"] #Career.all
  	deparments = ["ACCOUNT", "ACCT", "ACCTX", "ADVT", "AFST", "AF_AM_ST", "ALT_CERT", "AMER_ST", "AMES", "ANTHRO", "APP_PHYS", "ARABIC", "ART", "ART_HIST", "ASIAN_AM", "ASTRON", "BIOL_SCI", "BLAW", "BMD_ENG", "BUS_ALYS", "BUS_INST", "BUS_LAW", "CFS", "CHEM", "CHEM_ENG", "CHINESE", "CHSS", "CIC", "CIS", "CIV_ENV", "CLASSICS", "CLIN_PSY", "CLIN_RES", "CME", "CMN", "COG_SCI", "COMM_ST", "COMP_LIT", "CONDUCT", "COUN_PSY", "CRDV", "CSD", "DANCE", "DECS", "DECSX", "DIV_MED", "DSGN", "EARTH", "ECON", "EECS", "ENGLISH", "ENTR", "ENVR_POL", "ENVR_SCI", "EPI_BIO", "ES_APPM", "EXMMX", "FINANCE", "FINC", "FINCX", "FN_EXTND", "FRENCH", "GBL_HLTH", "GENET_CN", "GEN_CMN", "GEN_ENG", "GEN_LA", "GEN_MUS", "GEOG", "GERMAN", "GNDR_ST", "GREEK", "HDPS", "HDSP", "HEBREW", "HEMA", "HINDI", "HISTORY", "HQS", "HSR", "HUM", "IBIS", "IEMS", "IGP", "IMC", "INF_TECH", "INTG_SCI", "INTL", "INTLX", "INTL_ST", "IPLS", "ISEN", "ITALIAN", "JAPANESE", "JAZZ_ST", "JOUR", "JRN_WRIT", "JWSH_ST", "JW_LEAD", "KELLG_FE", "KELLG_MA", "KOREAN", "LATIN", "LATINO", "LAWSTUDY", "LDRSHP", "LEADERS", "LEAD_ART", "LEGAL_ST", "LING", "LIT", "LITARB", "LOC", "LRN_SCI", "MATH", "MAT_SCI", "MBIOTECH", "MCW", "MDVL_ST", "MECH_ENG", "MECN", "MECNX", "MECS", "MECSX", "MEDM", "MED_INF", "MED_SKIL", "MGMT", "MGMTX", "MHB", "MKTG", "MKTGX", "MMSS", "MORS", "MORSX", "MPD", "MPPA", "MSA", "MSC", "MSCI", "MSIA", "MSRC", "MSTP", "MS_ED", "MS_FT", "MS_HE", "MS_LOC", "MTS", "MUSEUM", "MUSIC", "MUSICOL", "MUSIC_ED", "MUS_COMP", "MUS_HIST", "MUS_TECH", "MUS_THRY", "NAV_SCI", "NEUROBIO", "NUIN", "OPNS", "OPNSX", "ORG_BEH", "ORTH", "PBC", "PERF_ST", "PERSIAN", "PHIL", "PHIL_NP", "PHYSICS", "PHYS_TH", "PIANO", "POLI_SCI", "PORT", "PREDICT", "PROJ_MGT", "PROJ_PMI", "PROS", "PSYCH", "PUB_HLTH", "QARS", "REAL", "RELIGION", "RTVF", "SCS", "SEEK", "SESP", "SHC", "SLAVIC", "SOCIOL", "SOC_POL", "SPANISH", "SPANPORT", "STAT", "STRINGS", "SWAHILI", "TEACH_ED", "TGS", "TH&DRAMA", "THEATRE", "TURKISH", "URBAN_ST", "VOICE", "WIND_PER", "WRITING"] #Department.all

  	careers.each do |career|
			deparments.each do |department|
				doc = get_data("4530", department, career)
				scrape_courses(doc, department)
			end # end  deparments
		end #end careers

  end

  def temp(department)
  	doc = get_data("4530", department, "UGRD")
  	scrape_courses(doc, department)
  end

	def authenticate()
		page = @agent.get('https://ses.ent.northwestern.edu/psp/s9prod/?cmd=login')

		login_form = page.form('login')
		login_form.set_fields(:userid => ENV['user'])
		login_form.set_fields(:pwd => ENV['pass'])
		login_form.action = 'https://ses.ent.northwestern.edu/psp/caesar/?cmd=?languageCd=ENG'

		page = @agent.submit(login_form, login_form.buttons.first)

		puts "authenticated"
	end

	def set_post_parameters()
		course_catalog_url = 'https://ses.ent.northwestern.edu/psc/caesar_6/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL?Page=SSR_CLSRCH_ENTRY'
		doc = @agent.get(course_catalog_url).parser

		@icsid = doc.xpath("//*[@id='ICSID']/@value").text
		@icelementnum = doc.xpath( "//*[@id='ICElementNum']/@value").text
		@icstatenum = doc.xpath("//*[@id='ICStateNum']/@value").text

		# doc.css("input[type='hidden']").map do |elm|
		#   ["name", "value"].map do |k| 
		#     elm.attributes[k].text
		#   end
		# end

		puts "set post parameters"

	end	
	
	def scrape_courses(doc, department)

		error = check_for_error(doc)

		if (error.present?)
			handle_error(error, department)
			return
		end

		courses = doc.search("span[id^='DERIVED_CLSRCH_DESCR200$']/text()").to_a

		puts courses

		partsCounter1 = 0

		courses.each_with_index { |x,i| 
			courses[i] = CGI.unescapeHTML(courses[i].to_s).delete!("^\u{0000}-\u{007F}")
			courses[i] =~ /(^\w+)(\s+)(\d+-\d+) - (.*)/
			department = $1
      number = $3
      title = $4
			sections = doc.search("div[id='win6div$ICField242GP$" + i.to_s + "'] > span[class='PSGRIDCOUNTER']/text()").to_s.gsub(/1.*of\s/, "").to_i
			locations = doc.search("div[id='win6divSSR_CLSRCH_MTG1$" + partsCounter1.to_s + "'] > table > tr")

			locLength = locations.length - 1


			puts "#{department} #{number} has #{sections} sections"
			sections.times { |section_counter|

				uniqueid_sec = doc.search("a[id='DERIVED_CLSRCH_SSR_CLASSNAME_LONG$" + section_counter + "']").text
				uniqueid_sec =~ /(\w+)-(\w+)\((\d+)\)/
				
				section = $1
      	lecdisc = $2
      	unique_id = $3

      	status = doc.search("div[id='win6divDERIVED_CLSRCH_SSR_STATUS_LONG$" + partsCounter2.to_s + "'] > div > img")[0]['alt']

				puts "-------------- #{uniqueid_sec} {status}"

				locLength.times { |blah|

					room = doc.search("span[id='MTG_ROOM$" + partsCounter1.to_s + "']").text
					instructor = doc.search("span[id='MTG_INSTR$" + partsCounter1.to_s + "']").text
					dates = doc.search("span[id='MTG_TOPIC$" + partsCounter1.to_s + "']").text
					seats = doc.search("span[id='NW_DERIVED_SS3_AVAILABLE_SEATS$" + partsCounter1.to_s + "']").text

				
					partsCounter1 += 1
				}

			}

			

		} # end courses.each_with_index
	end

	# def scrape_section()

	# 	sections.times { |x|
	# 		uniqueid_sec = doc.search("a[id='DERIVED_CLSRCH_SSR_CLASSNAME_LONG$" + partsCounter2.to_s + "']").text
	# 		uniqueid_sec =~ /(\w+)-(\w+)\((\d+)\)/
	# 		section = $1
 #      lecdisc = $2
 #      unique_id = $3

 #      days_time = doc.search("span[id='MTG_DAYTIME$" + partsCounter1.to_s + "']").text

 #      if (days_time != "TBA")
	# 			days_time =~ /^(\w+) (\d\d?:\d\d(AM|PM)) - (\d\d?:\d\d(AM|PM))/
	# 			days = $1
	# 			start_time = $2
	# 			end_time = $4
 #        		else
	# 			days = "TBA"
	# 			start_time = "TBA"
	# 			end_time = "TBA"
	# 		end

	# 		room = doc.search("span[id='MTG_ROOM$" + partsCounter1.to_s + "']").text
	# 		instructor = doc.search("span[id='MTG_INSTR$" + partsCounter1.to_s + "']").text
	# 		dates = doc.search("span[id='MTG_TOPIC$" + partsCounter1.to_s + "']").text
	# 		seats = doc.search("span[id='NW_DERIVED_SS3_AVAILABLE_SEATS$" + partsCounter1.to_s + "']").text
	# 		status = doc.search("div[id='win6divDERIVED_CLSRCH_SSR_STATUS_LONG$" + partsCounter2.to_s + "'] > div > img")[0]['alt']

	# 		# http://stackoverflow.com/questions/452859/inserting-multiple-rows-in-a-single-sql-query
 #  		# course_list.insert(:uniqueid => uniqueid, :dept => department, :course => course, :sec => sec, :title => title, :days => days, :start_time => start_time, :end_time => end_time, :room => room, :instructor => instructor, :seats => seats, :status => status, :datescraped => datescraped)
        
 #  		mo = days.include? ("Mo")
 #  		tu = days.include? ("Tu")
 #      we = days.include? ("We")
 #      th = days.include? ("Th")
 #      fr = days.include? ("Fr")

 #  		puts "#{subject} #{number} #{title} #{lecdisc} #{instructor} #{days} #{start_time} #{end_time} #{partsCounter1}"

 #  		course = Course.find_or_create_by_unique_id(unique_id) { |c|
 #  			c.term = term
 #      	c.subject = subject
 #      	c.number = number
 #      	c.section = section
 #      	c.title = title
 #      	c.M = mo ? 1 : 0
 #      	c.T = tu ? 1 : 0
 #      	c.W = we ? 1 : 0
 #      	c.R = th ? 1 : 0
 #      	c.F = fr ? 1 : 0
 #      	c.start = start_time
 #      	c.end = end_time
 #      	c.room = room
 #      	c.instructor = instructor
 #      	c.seats = seats
 #      	c.lecdisc = lecdisc
 #      	c.status = status
 #  		}

	# 		partsCounter1+=1
	# 		partsCounter2+=1
	# 	} # end parts.times
	# end


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

	def get_data(term, department, career)
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
	end

	def check_for_error(document)
		document.search("span[id^='DERIVED_CLSMSG_ERROR_TEXT']/text()")
	end

	def lastdoc
		agent.current_page().parser
	end

end