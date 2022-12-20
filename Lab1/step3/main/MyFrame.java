package main;

import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.Locale;

public class MyFrame extends JFrame{
    private static final int width = 1400;
    private static final int height = 250;

    JTextField textField1;
    JTextField textField2;
    JTextField textField3;
    JTextField textField4;
    JTextField textField5;

    JTextField textField6;

    JList<String> list1;
    JList<String> list2;
    JList<String> list3;

    JList<String> list4;

    BigDecimal max = new BigDecimal("1000000000000.0000000000");
    BigDecimal min = new BigDecimal("-1000000000000.0000000000");

    String[] data = new String[]{"   +   ", "   -   ", "   *   ", "   /   "};

    String[] roundModData = new String[]{"Математическое", "Бухгалтерское", "Усечение"};

    NumberFormat nf = NumberFormat.getInstance(Locale.US);
    DecimalFormat df = (DecimalFormat) nf;

    MyFrame(){
        super("Калькулятор");
        setSize(width, height);

        df.setParseBigDecimal(true);

        JPanel panel = new JPanel();

        textField1 = new JTextField();
        Panel panel1 = new Panel();
        panel1.add(textField1);
        panel1.setSize(220,45);
        textField1.setBounds(10,10,200,25);
        panel1.setLayout(null);

        list1 = new JList<>(data);
        list1.setSelectedIndex(0);
        Panel panel2 = new Panel();
        panel2.add(list1);

        JLabel label1 = new JLabel("(");
        Panel panel3 = new Panel();
        panel3.add(label1);

        textField2 = new JTextField();
        Panel panel4 = new Panel();
        panel4.add(textField2);
        panel4.setSize(220,45);
        textField2.setBounds(10,10,200,25);
        panel4.setLayout(null);

        list2 = new JList<>(data);
        list2.setSelectedIndex(0);
        Panel panel5 = new Panel();
        panel5.add(list2);

        textField3 = new JTextField();
        Panel panel6 = new Panel();
        panel6.add(textField3);
        panel6.setSize(220,45);
        textField3.setBounds(10,10,200,25);
        panel6.setLayout(null);

        JLabel label2 = new JLabel(")");
        Panel panel7 = new Panel();
        panel7.add(label2);

        list3 = new JList<>(data);
        list3.setSelectedIndex(0);
        Panel panel8 = new Panel();
        panel8.add(list3);

        textField4 = new JTextField();
        Panel panel9 = new Panel();
        panel9.add(textField4);
        panel9.setSize(220,45);
        textField4.setBounds(10,10,200,25);
        panel9.setLayout(null);

        JButton button = new JButton("=");
        Panel panel10 = new Panel();
        panel10.add(button);

        textField5 = new JTextField();
        Panel panel11 = new Panel();
        panel11.add(textField5);
        panel11.setSize(220,45);
        textField5.setBounds(10,10,200,25);
        panel11.setLayout(null);
        textField5.setEditable(false);

        JButton infoButton = new JButton("?");
        infoButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JOptionPane.showMessageDialog(null,"Выполнил: Прилепский Иван Игоревич, 4 курс, 4 группа, 2022 год", "Информация", JOptionPane.INFORMATION_MESSAGE);
            }
        });

        Panel panel12 = new Panel();
        panel12.add(infoButton);

        JLabel label = new JLabel("Введите числа.");

        Panel panel13 = new Panel();
        panel13.add(label);

        JPanel panel14 = new JPanel();

        list4 = new JList<>(roundModData);
        list4.setSelectedIndex(0);
        Panel panel15 = new Panel();
        panel15.add(list4);
        list4.addListSelectionListener(new ListSelectionListener() {
            @Override
            public void valueChanged(ListSelectionEvent e) {
                String value = textField5.getText().replaceAll(" ", "");
                if (!value.isEmpty()){
                    try {
                        BigDecimal val = (BigDecimal) df.parse(value);
                        textField6.setText(format(round(val)));
                    } catch (ParseException ex) {

                    }
                }
            }
        });

        textField6 = new JTextField();
        Panel panel16 = new Panel();
        panel16.add(textField6);
        panel16.setSize(220,45);
        textField6.setBounds(10,10,200,25);
        panel16.setLayout(null);
        textField6.setEditable(false);

        panel14.add(panel15);
        panel14.add(panel16);
        panel14.add(panel12);

        panel.add(panel1);
        panel.add(panel2);
        panel.add(panel3);
        panel.add(panel4);
        panel.add(panel5);
        panel.add(panel6);
        panel.add(panel7);
        panel.add(panel8);
        panel.add(panel9);
        panel.add(panel10);
        panel.add(panel11);

        JPanel center = new JPanel( new GridBagLayout());
        center.add(panel, new GridBagConstraints());

        JPanel center2 = new JPanel( new GridBagLayout());
        center2.add(panel14, new GridBagConstraints());

        add(center, BorderLayout.CENTER);
        add(panel13, BorderLayout.NORTH);
        add(center2, BorderLayout.SOUTH);

        button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {

                    textField5.setText("");
                    textField6.setText("");

                    if (!isSpacesValid(textField1.getText()) || !isSpacesValid(textField2.getText()) || !isSpacesValid(textField3.getText()) || !isSpacesValid(textField4.getText())){
                        label.setText("Ошибка: Неверный формат чисел.");
                        return;
                    }

                    BigDecimal value1 = (BigDecimal) df.parse(textField1.getText().replaceAll(" ", ""));
                    BigDecimal value2 = (BigDecimal) df.parse(textField2.getText().replaceAll(" ", ""));
                    BigDecimal value3 = (BigDecimal) df.parse(textField3.getText().replaceAll(" ", ""));
                    BigDecimal value4 = (BigDecimal) df.parse(textField4.getText().replaceAll(" ", ""));

                    if(value1.compareTo(min) < 0 || value1.compareTo(max) > 0
                            || value2.compareTo(min) < 0 || value2.compareTo(max) > 0
                            || value3.compareTo(min) < 0 || value3.compareTo(max) > 0
                            || value4.compareTo(min) < 0 || value4.compareTo(max) > 0){
                        label.setText("Ошибка: Число выходит за допустимые границы.");
                        return;
                    }

                    BigDecimal value;
                    switch (list2.getSelectedIndex()) {
                        default -> value = value2.add(value3);
                        case 1 -> value = value2.subtract(value3);
                        case 2 -> value = value2.multiply(value3);
                        case 3 -> {
                            if (value3.compareTo(new BigDecimal("0")) == 0) {
                                label.setText("Ошибка: Невозможно делить на 0.");
                                return;
                            }
                            value = value2.divide(value3, 10, RoundingMode.HALF_UP);
                        }
                    }
                    value = value.divide(new BigDecimal("1"), 10, RoundingMode.HALF_UP);

                    if(value.compareTo(min) < 0 || value.compareTo(max) > 0){
                        label.setText("Ошибка: Результат выходит за допустимые границы.");
                        return;
                    }

                    if (list3.getSelectedIndex() >= 2 && list1.getSelectedIndex() < 2){
                        switch (list3.getSelectedIndex()) {
                            default -> value = value.add(value4);
                            case 1 -> value = value.subtract(value4);
                            case 2 -> value = value.multiply(value4);
                            case 3 -> {
                                if (value4.compareTo(new BigDecimal("0")) == 0) {
                                    label.setText("Ошибка: Невозможно делить на 0.");
                                    return;
                                }
                                value = value.divide(value4, 10, RoundingMode.HALF_UP);
                            }
                        }
                        value = value.divide(new BigDecimal("1"), 10, RoundingMode.HALF_UP);

                        if(value.compareTo(min) < 0 || value.compareTo(max) > 0){
                            label.setText("Ошибка: Результат выходит за допустимые границы.");
                            return;
                        }

                        switch (list1.getSelectedIndex()) {
                            default -> value = value1.add(value);
                            case 1 -> value = value1.subtract(value);
                            case 2 -> value = value1.multiply(value);
                            case 3 -> {
                                if (value.compareTo(new BigDecimal("0")) == 0) {
                                    label.setText("Ошибка: Невозможно делить на 0.");
                                    return;
                                }
                                value = value1.divide(value, 10, RoundingMode.HALF_UP);
                            }
                        }
                    } else {
                        switch (list1.getSelectedIndex()) {
                            default -> value = value1.add(value);
                            case 1 -> value = value1.subtract(value);
                            case 2 -> value = value1.multiply(value);
                            case 3 -> {
                                if (value.compareTo(new BigDecimal("0")) == 0) {
                                    label.setText("Ошибка: Невозможно делить на 0.");
                                    return;
                                }
                                value = value1.divide(value, 10, RoundingMode.HALF_UP);
                            }
                        }
                        value = value.divide(new BigDecimal("1"), 10, RoundingMode.HALF_UP);

                        if(value.compareTo(min) < 0 || value.compareTo(max) > 0){
                            label.setText("Ошибка: Результат выходит за допустимые границы.");
                            return;
                        }

                        switch (list3.getSelectedIndex()) {
                            default -> value = value.add(value4);
                            case 1 -> value = value.subtract(value4);
                            case 2 -> value = value.multiply(value4);
                            case 3 -> {
                                if (value4.compareTo(new BigDecimal("0")) == 0) {
                                    label.setText("Ошибка: Невозможно делить на 0.");
                                    return;
                                }
                                value = value.divide(value4, 10, RoundingMode.HALF_UP);
                            }
                        }
                    }

                    value = value.divide(new BigDecimal("1"), 10, RoundingMode.HALF_UP);

                    if(value.compareTo(min) < 0 || value.compareTo(max) > 0){
                        label.setText("Ошибка: Результат выходит за допустимые границы.");
                        return;
                    }

                    textField5.setText(format(value));
                    textField6.setText(format(round(value)));

                    label.setText(" ");

                } catch (Exception ex){
                    if(textField1.getText().isEmpty() || textField2.getText().isEmpty()){
                        label.setText("Ошибка: Числа не введены.");
                    } else {
                        label.setText("Ошибка: Неверный формат чисел.");
                    }
                }
            }
        });

        textField1.setText("0");
        textField2.setText("0");
        textField3.setText("0");
        textField4.setText("0");

        AbstractDocument document1 = (AbstractDocument) textField1.getDocument();
        document1.setDocumentFilter(new NumberFilter(textField1));

        AbstractDocument document2 = (AbstractDocument) textField2.getDocument();
        document2.setDocumentFilter(new NumberFilter(textField2));

        AbstractDocument document3 = (AbstractDocument) textField3.getDocument();
        document3.setDocumentFilter(new NumberFilter(textField3));

        AbstractDocument document4 = (AbstractDocument) textField4.getDocument();
        document4.setDocumentFilter(new NumberFilter(textField4));

        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setResizable(false);
        this.setLocationRelativeTo(null);
        this.setVisible(true);
    }

    BigDecimal round(BigDecimal value){
        RoundingMode rMode = RoundingMode.HALF_UP;
        switch (list4.getSelectedIndex()){
            case 1 -> rMode = RoundingMode.HALF_EVEN;
            case 2 -> rMode = RoundingMode.DOWN;
        }

        return value.divide(new BigDecimal("1"), 0, rMode);
    }

    String format(BigDecimal decimal){
        String value = decimal.divide(new BigDecimal("1"), 6, RoundingMode.HALF_UP).toString();

        value = value.replaceAll(" ", "");

        for (int i = value.indexOf('.') - 3; i > 0; i -= 3){
            value = value.substring(0, i) + " " + value.substring(i);
        }

        if (value.charAt(0) == '-' && value.charAt(1) == ' '){
            value = "-" + value.substring(2);
        }

        for (int i = value.length() - 1;; i--){
            if (value.charAt(i) == '0'){
                value = value.substring(0, i);
                continue;
            }
            if (value.charAt(i) == '.'){
                value = value.substring(0, i);
            }
            break;
        }

        return value;
    }

    boolean isSpacesValid(String value){
        if(!value.contains(" ")){
            return true;
        }

        int dot = value.indexOf(".");
        dot = dot == -1? value.length() : dot;

        for (int i = value.length() - 1; i >= 0; i--){
            if (i > dot){
                if (value.charAt(i) == ' '){
                    return false;
                }
            } else if(i < dot) {
                if (value.charAt(i) == ' ' && (dot - i) % 4 != 0){
                    return false;
                }
                if ((dot - i) % 4 == 0 && value.charAt(i) != ' '){
                    return false;
                }
            }
        }

        return true;
    }
}