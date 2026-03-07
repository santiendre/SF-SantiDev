@RestResource(urlMapping='/trivia/questions/*')
global class TriviaQuestionService {

    @HttpPost
    global static ResponseWrapper postQuestions() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        List<QuestionWrapper> questions = new List<QuestionWrapper>();
        List<Trivia_Question__c> questionsToInsert = new List<Trivia_Question__c>();
        try {
            questions = (List<QuestionWrapper>) JSON.deserialize(body, List<QuestionWrapper>.class);
        } catch(System.JSONException jsonE) {
            try {
                QuestionWrapper question = (QuestionWrapper) JSON.deserialize(body, QuestionWrapper.class);
                questions.add(question);
            } catch(Exception e) {
                return new ResponseWrapper(0, 0, e.getMessage());
            }
        } catch(Exception e) {
            return new ResponseWrapper(0, 0, e.getMessage());
        }
        for(QuestionWrapper qw : questions) {
            questionsToInsert.add(new Trivia_Question__c(
                Question__c = qw.question,
                Option_A__c = qw.optionA,
                Option_B__c = qw.optionB,
                Option_C__c = qw.optionC,
                Option_D__c = qw.optionD,
                Correct_Answer__c = qw.correctAnswer,
                Difficulty__c = String.valueOf((Integer) qw.difficulty),
                Category__c = qw.category,
                Active__c = true
            ));
        }
        List<Database.SaveResult> results =  Database.insert(questionsToInsert, false);
        Integer loaded = 0;
        Integer failed = 0;
        for(Database.SaveResult sr : results) {
            if(sr.isSuccess()) {
                loaded += 1;
            } else {
                failed += 1;
            }
        }
        return new ResponseWrapper(loaded, failed, loaded + ' questions loaded - ' + failed + ' questions failed');
    }

    public class QuestionWrapper {
        public String question;
        public String optionA;
        public String optionB;
        public String optionC;
        public String optionD;
        public String correctAnswer;
        public Integer difficulty;
        public String category;
    }

    public class ResponseWrapper {
        public Integer questionsLoaded;
        public Integer questionsFailed;
        public String message;

        public ResponseWrapper(Integer qLoaded, Integer qFailed, String message) {
            this.questionsLoaded = qLoaded;
            this.questionsFailed = qFailed;
            this.message = message;
        }
    }
}