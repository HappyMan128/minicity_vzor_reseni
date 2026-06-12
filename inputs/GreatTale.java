package exams;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Objects;

/**
 * Hlavni trida pro ukol, pouziva pomocne rozhrani a dve tridy umistene v souboru
 * Trida TextMSG je pro ukazku, funkcionalitu doplnujete zde (GreatTale) a do Tridy {@code Book}
 */
public class GreatTale {

    /**
     * Tato metoda by mela zvladnout praci s TextMsg i Book
     */
    static int wordCount(Readable toCount){
        String read = toCount.getText();
        return read.split(" ").length;
    }

    static void init(){
        ArrayList<String> LOTR = new ArrayList<>();
        LOTR.add("One Ring to rule them all."); //stranka #1
        LOTR.add("Folk takes their peril with them into Lorien.");
        LOTR.add("Hinder me? Thou fool. No living man may hinder me!");
        LOTR.add("Don’t the great tales never end?"); //stranka #4

        TextMsg msg = new TextMsg("Johnny", "27-06-2003", "Oh, Hi Mark!");
        Book LordOTR = new Book("Lord of the rings", "J. R. R. Tolkien", "29-07-1968", 243, LOTR);
        Book LordOfTheRings = new Book("Lord of the rings", "John Ronald Reuel Tolkien", "29-07-1968", 243, LOTR);
        System.out.println(LordOTR.equals(LordOfTheRings));//melo by vratit True, maji stejne knizni ID (IBM)

        System.out.println("Wordcount for LOTR: "  + wordCount(LordOTR));
        System.out.println("Wordcount for Msg: " + wordCount(msg));

        System.out.println("LOTR read:");
        LordOfTheRings.read();

        System.out.println("Message read:");
        msg.read();
    }

    public static void main(String[] args) {
        init();
    }


}
interface Readable {
    void read();

    String getText();

}

/**
 * Zde je vas ukol pro implementaci dle zadani
 */
class Book implements Readable{
        String name, author, date;
        int IBM;
        ArrayList<String> pages;

    public Book(String name, String author, String date, int IBM, ArrayList<String> pages) {
        this.name = name;
        this.author = author;
        this.date = date;
        this.IBM = IBM;
        this.pages = pages;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Book book = (Book) o;
        return IBM == book.IBM && Objects.equals(name, book.name) && Objects.equals(author, book.author) && Objects.equals(date, book.date) && Objects.equals(pages, book.pages);
    }

//    @Override
//    public int hashCode() {
//        return Objects.hash(name, author, date, IBM, pages);
//    }

    @Override
    public void read() {
        System.out.println(name);
        System.out.println("Written by: " + author);
        for (int i = 0; i < pages.size(); i++) {
            System.out.println( (i+1) + "/" + pages.size());
            System.out.println(pages.get(i));
        }
    }

    @Override
    public String getText() {
        StringBuilder result = new StringBuilder();

        for (String page : pages){
            result.append(page);
            result.append(" \n");
        }
        return result.toString();
    }
}

class TextMsg  implements Readable, Comparable<TextMsg>{
    String sender;
    String date;
    String text;


    public TextMsg(String sender, String date, String text) {
        this.sender = sender;
        this.date = date;
        this.text = text;
    }

    @Override
    public int compareTo(TextMsg o) {
        String another = o.sender;
        return this.sender.compareTo(another);
    }

    @Override
    public void read() {
        System.out.println("Message received " + date);
        System.out.println(sender + " wrote: ");
        System.out.println(text);
    }

    @Override
    public String getText() {
        return text;
    }
}
