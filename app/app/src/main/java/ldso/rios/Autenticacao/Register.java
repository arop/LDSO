package ldso.rios.Autenticacao;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import ldso.rios.DataBases.DB_functions;
import ldso.rios.DataBases.User;
import ldso.rios.MainActivities.GuardaRios;
import ldso.rios.MainActivities.Homepage;
import ldso.rios.R;

import static ldso.rios.MainActivities.Homepage.PREFS_NAME;

public class Register extends AppCompatActivity {

    protected EditText mUsername;
    protected EditText mEmail;
    protected EditText mPassword;
    protected EditText mPasswordConfirm;

    protected EditText mTelefone;
    protected EditText mProfissao;
    protected EditText mHabilitacoes;
    protected Switch mFormacao;

    protected Button mRegisterButton;
    protected User user;
    private static final int REQUEST_READ_CONTACTS = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("Registo");
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        //init
        mUsername=(EditText)findViewById(R.id.UserNameRegisterEditText);
        mEmail=(EditText)findViewById(R.id.EmailRegisterEditText);
        mPassword=(EditText)findViewById(R.id.PasswordRegisterEditText);
        mPasswordConfirm=(EditText)findViewById(R.id.PasswordConfirmRegisterEditText);

        mTelefone=(EditText)findViewById(R.id.TelefoneRegisterEditText);
        mHabilitacoes=(EditText)findViewById(R.id.HabilitacoesRegisterEditText);
        mProfissao=(EditText)findViewById(R.id.ProfissaoRegisterEditText);
        mFormacao=(Switch) findViewById(R.id.FormacaoRegisterSwitch);

        mRegisterButton=(Button)findViewById(R.id.RegisterButton);
        user=new User();
        user.setId(-1);
        user.setName("teste");
        user.setEmail("teste@email.com");
        user.setPassword("teste");
    }

    public void register(View view){
        //get form
        String username=mUsername.getText().toString().trim();
        String password=mPassword.getText().toString().trim();
        String password_confirm=mPasswordConfirm.getText().toString().trim();
        String email=mEmail.getText().toString().trim();

        String telef=mTelefone.getText().toString().trim();
        String profissao=mProfissao.getText().toString().trim();
        String habilitacoes=mHabilitacoes.getText().toString().trim();
        Boolean formacao=mFormacao.isChecked();

        boolean erro=false;
        if(username.length()==0){
            mUsername.setError("Preencha o campo");
            erro=true;
        }
        if( ! android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches() ){
            mEmail.setError("Endereço de email incorreto");
            erro=true;
        }
        if(password.length()<8){
            mPassword.setError("Tem de ter mais de 8 caracteres");
            erro=true;
        }
        if(!password_confirm.equals(password )){
            mPassword.setError("Password nao corresponde");
            erro=true;
        }
        if(telef.length()!=9){
            mTelefone.setError("Tem de ter 9 caracteres");
            erro=true;
        }
        if (erro) return;
        try {
            DB_functions.saveUser(username,email,password,password_confirm,telef,profissao,habilitacoes,formacao,this);
        } catch (IOException e) {
            Toast.makeText(Register.this, "Erro ao registar utilizador", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        } catch (JSONException e) {
            Toast.makeText(Register.this, "Erro ao registar utilizador", Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }

        Intent intent = new Intent(getApplicationContext(), Homepage.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);

        //set user
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

    public void register_response(final Boolean error, final String error_txt, final Register reg, final JSONObject obj) {

        new Thread()
        {
            public void run()
            {
                Register.this.runOnUiThread(new Runnable()
                {
                    public void run()
                    {
                        Toast toast;
                        Context context = getApplicationContext();
                        if (error){
                            toast = Toast.makeText(context, error_txt, Toast.LENGTH_LONG);
                            toast.show();
                        }
                        else {
                            toast = Toast.makeText(context, "Registo bem sucedido ", Toast.LENGTH_LONG);
                            toast.show();

                            try {
                                login_response_after_register(error,error_txt,obj.get("authentication_token").toString(),obj.get("nome").toString(),obj.get("email").toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                });
            }
        }.start();
    }

    public void login_response_after_register(final Boolean error, final String error_txt, final String authentication, final String nome, final String email) {

        new Thread()
        {
            public void run()
            {
                Register.this.runOnUiThread(new Runnable()
                {
                    public void run()
                    {
                        Toast toast;
                        Context context = getApplicationContext();
                        if (error){
                            toast = Toast.makeText(context, error_txt, Toast.LENGTH_LONG);
                            toast.show();
                        }
                        else {
                            toast = Toast.makeText(context, "Bem vindo "+nome, Toast.LENGTH_LONG);
                            toast.show();

                            // We need an Editor object to make preference changes.
                            // All objects are from android.context.Context
                            SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                            SharedPreferences.Editor editor = settings.edit();
                            editor.putString("token",authentication);
                            editor.putString("name",nome);
                            editor.putString("email",email);

                            // Commit the edits!
                            editor.commit();
                            finish();
                        }
                    }
                });
            }
        }.start();
    }

}