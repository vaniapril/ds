package main;

import javax.swing.*;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;
import javax.swing.text.DocumentFilter;

class NumberFilter extends DocumentFilter {

    JTextField textField;

    NumberFilter(JTextField textField){
        this.textField = textField;
    }

    @Override
    public void remove(FilterBypass fb, int offset, int length) throws BadLocationException {
        Document oldDoc = fb.getDocument();
        String value = oldDoc.getText(0, oldDoc.getLength());

        value = value.substring(0, offset) + value.substring(offset + length);
        onEdit(fb, oldDoc.getLength(), value, offset);
    }

    @Override
    public void insertString(FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
        Document oldDoc = fb.getDocument();
        String value = oldDoc.getText(0, oldDoc.getLength());

        value = value.substring(0, offset) + string + value.substring(offset);
        onEdit(fb,oldDoc.getLength(), value, offset + string.length());
    }

    @Override
    public void replace(FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
        Document oldDoc = fb.getDocument();
        String value = oldDoc.getText(0, oldDoc.getLength());

        value = value.substring(0, offset) + text + value.substring(offset + length);
        onEdit(fb,oldDoc.getLength(), value, offset + text.length());
    }

    public void onEdit(FilterBypass fb, int length, String value, int newPos) throws BadLocationException {
        value = value.replaceAll(",", ".");

        for (int i = 0; i < value.length();){
            char c = value.charAt(i);

            if (Character.isDigit(c) || c == '-' || c == '.'|| c == ' '){
                i++;
            } else {
                value = value.substring(0, i) + value.substring(i + 1);
                if(i <= newPos){
                    newPos--;
                }
            }
        }

        boolean hasDigit = false;
        boolean hasDot = false;

        for (int i = 0; i < value.length();){
            char c = value.charAt(i);

            if (i == 0 && c == '-'){
                i++;
                continue;
            }

            if(Character.isDigit(c)){
                if (c != '0' || hasDigit){
                    hasDigit = true;
                    i++;
                    continue;
                } else {
                    boolean nextDot = true;
                    for (int i2 = i + 1; i2 < value.length(); i2++){
                        if (value.charAt(i2) == ' ') continue;
                        if (value.charAt(i2) == '.'){
                            break;
                        } else {
                            nextDot = false;
                        }
                    }
                    if (nextDot){
                        hasDigit = true;
                        i++;
                        continue;
                    }
                }
            }

            if (c == '.' && !hasDot && hasDigit){
                hasDot = true;
                i++;
                continue;
            }

            if (c == ' '){
                i++;
                continue;
            }

            value = value.substring(0, i) + value.substring(i + 1);
            if(i <= newPos){
                newPos--;
            }
        }

        fb.replace(0, length, value, null);
        textField.setCaretPosition(newPos);
    }
}
