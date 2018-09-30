function flipdecision(hObject, eventdata, ~)

    button = get(hObject);

    choice = button.String;

    sourcewindow = button.Parent;

    set(sourcewindow, 'UserData', choice);

    uiresume

end