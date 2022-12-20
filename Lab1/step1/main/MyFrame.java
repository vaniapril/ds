package main;

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;

public class MyFrame extends JFrame{
    private static final int width = 850;
    private static final int height = 150;

    JTextField textField1;
    JTextField textField2;
    JTextField textField3;

    JList<String> list;

    BigDecimal max = new BigDecimal("1000000000000.000000");
    BigDecimal min = new BigDecimal("-1000000000000.000000");

    MyFrame(){
        super("Калькулятор");
        setSize(width, height);

        JPanel panel = new JPanel();

        textField1 = new JTextField();
        Panel panel1 = new Panel();
        panel1.add(textField1);
        panel1.setSize(220,45);
        textField1.setBounds(10,10,200,25);
        panel1.setLayout(null);

        String[] data = new String[]{"   +   ", "   -   "};
        list = new JList<>(data);
        list.setSelectedIndex(0);
        Panel panel2 = new Panel();
        panel2.add(list);

        textField2 = new JTextField();
        Panel panel3 = new Panel();
        panel3.add(textField2);
        panel3.setSize(220,45);
        textField2.setBounds(10,10,200,25);
        panel3.setLayout(null);

        JButton button = new JButton("=");
        Panel panel4 = new Panel();
        panel4.add(button);

        textField3 = new JTextField();
        Panel panel5 = new Panel();
        panel5.add(textField3);
        panel5.setSize(220,45);
        textField3.setBounds(10,10,200,25);
        panel5.setLayout(null);
        textField3.setEditable(false);

        JButton infoButton = new JButton("?");
        infoButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JOptionPane.showMessageDialog(null,"Выполнил: Прилепский Иван Игоревич, 4 курс, 4 группа, 2022 год", "Информация", JOptionPane.INFORMATION_MESSAGE);
            }
        });

        Panel panel7 = new Panel();
        panel7.add(infoButton);

        JLabel label = new JLabel("Введите числа.");

        Panel panel6 = new Panel();
        panel6.add(label);

        panel.add(panel1);
        panel.add(panel2);
        panel.add(panel3);
        panel.add(panel4);
        panel.add(panel5);
        panel.add(panel7);

        JPanel center = new JPanel( new GridBagLayout() );
        center.add(panel, new GridBagConstraints() );

        add(center, BorderLayout.CENTER);
        add(panel6, BorderLayout.SOUTH);

        button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    NumberFormat nf = NumberFormat.getInstance(Locale.US);
                    DecimalFormat df = (DecimalFormat) nf;
                    df.setParseBigDecimal(true);

                    BigDecimal value1 = (BigDecimal) df.parse(textField1.getText());
                    BigDecimal value2 = (BigDecimal) df.parse(textField2.getText());

                    if(value1.compareTo(min) < 0 || value1.compareTo(max) > 0 || value2.compareTo(min) < 0 || value2.compareTo(max) > 0){
                        label.setText("Ошибка: Число выходит за допустимые границы.");
                        return;
                    }

                    BigDecimal value = list.getSelectedIndex() == 0? value1.add(value2) : value1.subtract(value2);

                    if(value.compareTo(min) < 0 || value.compareTo(max) > 0){
                        label.setText("Ошибка: Результат выходит за допустимые границы.");
                        return;
                    }

                    textField3.setText(value.toString());
                    label.setText("  ");
                } catch (Exception ex){
                    if(textField1.getText().isEmpty() || textField2.getText().isEmpty()){
                        label.setText("Ошибка: Числа не введены.");
                    } else {
                        label.setText("Ошибка: Неверный формат чисел.");
                    }
                }
            }
        });

        AbstractDocument document1 = (AbstractDocument) textField1.getDocument();
        document1.setDocumentFilter(new NumberFilter(textField1));

        AbstractDocument document2 = (AbstractDocument) textField2.getDocument();
        document2.setDocumentFilter(new NumberFilter(textField2));

        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setResizable(false);
        this.setLocationRelativeTo(null);
        this.setVisible(true);
    }

}