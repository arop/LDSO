package engenheiro.rios.IRR;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;

import engenheiro.rios.GuardaRios;
import engenheiro.rios.Login;
import engenheiro.rios.R;

public class IRR_1_4 extends AppCompatActivity {
    protected LinearLayout linearLayout;
    ArrayList<CheckBox> list;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_irr_1_4);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("Novo Formulario");
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        TextView irr_textview_name_main= (TextView) this.findViewById(R.id.irr_textview_name_main);
        irr_textview_name_main.setText("Hidrogeomorfologia");

        TextView irr_textview_name= (TextView) this.findViewById(R.id.irr_textview_name);
        irr_textview_name.setText("Substrato das margens (selecionar os que tem mais de 35%)");

        linearLayout = (LinearLayout) this.findViewById(R.id.irr_linear);
        String[] array=new String[]{
                "Solo argiloso",
                "Arenoso",
                "Pedregoso",
                "Rochoso",
                "Artificial pedra",
                "Artificial Betão(5)"
        };
        list=Form_functions.createCheckboxes(array,linearLayout,this);



    }

    public void goto_next(View view){
        startActivity(new Intent(this, IRR_1_5.class));
        this.overridePendingTransition(0, 0);

    }

    public void goto_previous(View view){
        this.finish();
        this.overridePendingTransition(0, 0);
    }




    //menu action bar
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_homepage, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if(id==R.id.navigate_guardarios)
            startActivity(new Intent(this,GuardaRios.class));
        if(id==R.id.navigate_account)
            startActivity(new Intent(this,Login.class));
        return super.onOptionsItemSelected(item);
    }

}

