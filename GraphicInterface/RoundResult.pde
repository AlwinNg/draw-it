class RoundResult{
    int roundNumber;
    String item;
    String prediction;
    boolean guessed;
    int points;
    int scoreAfter;

    RoundResult(int roundNumber, String item, String prediction, boolean guessed, int points, int scoreAfter){
        this.roundNumber = roundNumber;
        this.item = item;
        this.prediction = prediction;
        this.guessed = guessed;
        this.points = points;
        this.scoreAfter = scoreAfter;
    }
}