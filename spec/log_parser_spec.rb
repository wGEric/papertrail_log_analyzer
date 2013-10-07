require "papertrail_log_analyzer/log_parser"

describe PapertrailLogAnalyzer::LogParser do
  it "Returns correct regular expression" do
    PapertrailLogAnalyzer::LogParser.get_regex('duration').should eq(/duration=(\d+)ms/)
    PapertrailLogAnalyzer::LogParser.get_regex('db').should eq(/db=(\d+)ms/)
    PapertrailLogAnalyzer::LogParser.get_regex('view').should eq(/view=(\d+)ms/)
    PapertrailLogAnalyzer::LogParser.get_regex('foobar').should eq(/foobar=(\d+)ms/)
    PapertrailLogAnalyzer::LogParser.get_regex('foo[]bar').should eq(/foo\[\]bar=(\d+)ms/)
  end

  it "parses param correctly" do
    PapertrailLogAnalyzer::LogParser.parse_param('Oct  5 15:32:57 6.www_ip-10-118-225-238 production.log: 71.191.14.163 GET /materials/71736 action=materials#show format=html status=200 duration=763ms db=64ms view=194ms allocated_objects=76220 params={"id"=>"71736"}', 'duration').should eq(763)
    PapertrailLogAnalyzer::LogParser.parse_param('Oct  5 15:33:00 2.www_ip-10-83-37-243 production.log: Rendering materials/index', 'duration').should eq(nil)
  end

  it "Parses logs" do
    results = PapertrailLogAnalyzer::LogParser.parse([
      'Oct  5 15:32:53 3.www_ip-10-114-51-127 production.log: 10.112.14.112 GET /status action=application#status status=200 duration=0ms db=2ms view=0ms allocated_objects=466',
      'Oct  5 15:32:53 2.www_ip-10-83-37-243 production.log: 10.112.14.112 GET /status action=application#status status=200 duration=0ms db=0ms view=0ms allocated_objects=465',
      'Oct  5 15:32:53 1.www_ip-10-203-51-199 production.log: 10.112.14.112 GET /status action=application#status status=200 duration=0ms db=37ms view=0ms allocated_objects=467',
      'Oct  5 15:32:53 3.www_ip-10-114-51-127 production.log: 184.38.229.47 GET /tutorial/remember_state?show=true action=tutorial#remember_state format=js status=200 duration=2ms db=1ms view=0ms allocated_objects=1212 params={"show"=>"true"}',
      'Oct  5 15:32:57 6.www_ip-10-118-225-238 production.log: Rendering template within layouts/fixed',
      'Oct  5 15:32:57 6.www_ip-10-118-225-238 production.log: Rendering materials/show',
      'Oct  5 15:32:57 6.www_ip-10-118-225-238 production.log: [AWS S3 200 0.074718 0 retries] list_objects(:bucket_name=>"files.masteryconnect.com",:max_keys=>1000,:prefix=>"docs/56598")',
      'Oct  5 15:32:57 6.www_ip-10-118-225-238 production.log: 71.191.14.163 GET /materials/71736 action=materials#show format=html status=200 duration=763ms db=64ms view=194ms allocated_objects=76220 params={"id"=>"71736"}',
      'Oct  5 15:33:00 4.www_ip-10-85-10-252 production.log: 70.131.127.3 POST /save_score/1946662/1056858/0 action=scores#create format=json status=200 duration=29ms db=49ms view=0ms allocated_objects=19817 params={"v"=>"2", "assessment_id"=>"1056858", "score_id"=>"0", "student_id"=>"1946662", "method"=>:put, "score"=>{"answers"=>"[\"B\",\"B\",\"A\",\"D\",\"B\",\"A\",\"C\",\"A\",\"A\",\"A\",\"C\",\"C\",\"B\",\"B\"]", "value"=>"6"}, "authenticity_token"=>"uzqdkP6FxnuR2annGrfQnUlKdU70smJlvIg9Zme0Z+o="}',
      'Oct  5 15:33:00 2.www_ip-10-83-37-243 production.log: Rendering template within layouts/fixed',
      'Oct  5 15:33:00 2.www_ip-10-83-37-243 production.log: Rendering materials/index',
      'Oct  5 15:33:00 2.www_ip-10-83-37-243 production.log: 71.191.14.163 GET /materials?filter%5Balignment_type%5D=0&filter%5Bclass_objective_id%5D=&filter%5Binclude_substandards%5D=0&filter%5Bobjective_id%5D=&filter%5Bpathway_id%5D=5&filter%5Bprivacy%5D=0&filter%5Bscore_type%5D=-1&filter%5Bstate_id%5D=57&filter%5Bsubject_id%5D=3&filter%5Buploaded_by%5D=0&page=17&sort%5Bby%5D=materials.created_at&sort%5Bdir%5D=desc action=materials#index format=html status=200 duration=1252ms db=277ms view=757ms allocated_objects=470298 params={"filter"=>{"objective_id"=>"", "subject_id"=>"3", "state_id"=>"57", "score_type"=>"-1", "uploaded_by"=>"0", "privacy"=>"0", "pathway_id"=>"5", "class_objective_id"=>"", "include_substandards"=>"0", "alignment_type"=>"0"}, "sort"=>{"dir"=>"desc", "by"=>"materials.created_at"}, "page"=>"17"}',
      'Oct  5 15:33:03 2.www_ip-10-83-37-243 production.log: Redirected to http://www.bubblescore.com/x/Mjc4NVJpVEk2ei9sRQ==/7a5fd487f951ecccad9ad681bcd8ffa4c795a040',
      'Oct  5 15:33:03 2.www_ip-10-83-37-243 production.log: 184.38.229.47 GET /switch action=pages#cross_link format=html status=302 location=http://www.bubblescore.com/x/Mjc4NVJpVEk2ei9sRQ==/7a5fd487f951ecccad9ad681bcd8ffa4c795a040 duration=3ms db=1ms allocated_objects=1232'
    ])

    results[:number].should eq(8)
    results[:duration_times].size.should eq(8)
    results[:db_times].size.should eq(8)
    results[:view_times].size.should eq(7)
  end
end
