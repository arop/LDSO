package ldso.rios.Form.IRR.Perguntas;

import android.content.Context;
import android.graphics.Color;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.io.Serializable;
import java.util.ArrayList;

import ldso.rios.Form.IRR.Pergunta;
import ldso.rios.Form.Form_functions;

/**
 * Created by filipe on 24/11/2015.
 */
public class checkPergunta extends Pergunta implements Serializable {


    private static final long serialVersionUID = -3522050436780683216L;
    protected ArrayList<CheckBox> check_list;

    public checkPergunta(String[] options, int[] images,String title, String subtitle, Boolean obly, Boolean other_option) {
        super(options,images, title, subtitle, obly, other_option);

    }

    @Override
    public void generate(LinearLayout linearLayout, Context context) {
        Form_functions.createTitleSubtitle(this.title,this.subtitle,linearLayout,context);

        this.linearLayout=linearLayout;
        this.context=context;
        this.check_list= Form_functions.createCheckboxes(this.options,this.images,this.linearLayout,this.context);

        if (this.other_option) {
            this.other = new EditText(context);
            this.other.setHint("Outro");
            linearLayout.addView(other);
        }
    }

    @Override
    public void generateView(LinearLayout linearLayout, Context context) {
        LinearLayout.LayoutParams radioParams;
        radioParams = new LinearLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        radioParams.setMargins(0, 100, 0, 20);
        TextView textView=new TextView(context);
        textView.setText(this.title + " - " + this.subtitle);
        textView.setTextColor(Color.BLACK);
        textView.setTextSize(20);
        textView.setLayoutParams(radioParams);
        linearLayout.addView(textView);

        this.linearLayout=linearLayout;
        this.context=context;
        this.check_list= Form_functions.createCheckboxes(this.options,null,this.linearLayout,this.context);
        for(CheckBox cb:this.check_list)
            cb.setEnabled(false);

    }

    @Override
    public void getAnswer() {
        if (check_list==null)
        {
            ArrayList<Integer> resposta_nula= new ArrayList<Integer>();
            for(String o :this.options)
                resposta_nula.add(0);
            this.response= resposta_nula;
            if (other_option)
                this.other_text="";
        }
        else {
            this.response = Form_functions.getCheckboxes(check_list);
            this.other_text=this.other.getText().toString();
        }
    }

    @Override
    public void forceresponse() {

    }

    @Override
    public void setAnswer() {
        ArrayList<Integer> al= (ArrayList<Integer>) this.response;
        if(al==null)
            return;
        for (int i=0;i<check_list.size();i++){
            if(al.get(i)==1)
                check_list.get(i).setChecked(true);
        }
        if (this.other_option)
        this.other.setText(this.other_text);
    }

    @Override
    public Object getList() {

        return this.check_list ;
    }

}
