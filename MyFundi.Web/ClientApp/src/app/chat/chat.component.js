"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
//import { modifyHasPopulatedPage } from '../../imports.js';
var ChatComponent = /** @class */ (function () {
    function ChatComponent() {
    }
    ChatComponent.prototype.normalizeMessage = function (message) {
        return message.replace(/@@[a-zA-Z0-9\.]+:/, ':');
    };
    ChatComponent.prototype.LoadUserList = function () {
        jQuery.ajax({
            url: "/Chat/GetUserList",
            type: "GET",
            dataType: "json",
            success: this.AddUserToList
        });
    };
    ChatComponent.prototype.AddUserToList = function (userList) {
        var userListCont = document.getElementById('radioList');
        var checkbox = null;
        for (var i = 0; i < userList.length; i++) {
            if (userList[i] !== '@User.Identity.Name') {
                //only create checkbox if not exists:
                var length = jQuery(userListCont).find('input:checkbox[value="' + userList[i] + '"]').length;
                if (length === 0) {
                    checkbox = this.CreateCheckbox('userList', userList[i]);
                    jQuery(checkbox).css('color', 'green');
                    var li = document.createElement("li");
                    var lb = document.createElement("span");
                    lb.innerHTML = userList[i].substring(0, userList[i].indexOf('@@'));
                    jQuery(li).append(checkbox);
                    jQuery(lb).css('margin-left', '5px;');
                    jQuery(li).append(lb);
                    jQuery(userListCont).append(li);
                }
            }
        }
    };
    ChatComponent.prototype.CreateCheckbox = function (name, value) {
        var element = document.createElement("input");
        var id = name + value;
        element.setAttribute('type', 'checkbox');
        element.setAttribute('value', value);
        element.setAttribute('name', name);
        element.setAttribute('id', id);
        return element;
    };
    ChatComponent.prototype.IsInSecretRoom = function () {
        var userName = '@User.Identity.Name';
        //Create Client Object:
        var client = { Username: userName, Message: '' };
        var jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Chat/IsInPrivateRoom",
            type: "POST",
            data: jsonData,
            dataType: "json",
            contentType: "application/json",
            success: function (data) {
                if (data !== 'True') {
                    document.location.href = '/Adhoc/PublicChat';
                }
            }
        });
    };
    ChatComponent.prototype.ClearRoom = function (room) {
        jQuery.ajax({
            url: "/Chat/ClearPrivateRoom",
            type: "GET"
        });
        document.location.href = '/Adhoc/PublicChat';
    };
    ChatComponent.prototype.ExitRoom = function () {
        var userName = '@User.Identity.Name';
        //Create Client Object:
        var client = { Username: userName, Message: 'Client has exited the Secret Room.\n' };
        var jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Chat/ExitPrivateRoom",
            type: "POST",
            dataType: "json",
            data: jsonData,
            contentType: "application/json"
        });
        document.location.href = '/Adhoc/PublicChat';
    };
    ChatComponent.prototype.wasClicked = function () {
        var userName = '@User.Identity.Name';
        var message = jQuery('#txtTypeHere').val();
        jQuery('#txtTypeHere').val('');
        //Create Client Object:
        var client = { Username: userName, Message: message };
        var jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Chat/AddMessagePrivateRoom",
            type: "POST",
            dataType: "json",
            data: jsonData,
            contentType: "application/json"
        });
    };
    ChatComponent.prototype.getMsgs = function () {
        var This;
        setTimeout("LoadUserList()", 10000);
        jQuery.ajax({
            url: "/Chat/GetMessage/SecretRoom",
            type: "GET",
            dataType: "html",
            contentType: "application/json",
            success: This.GotMessagePrivateRoom,
            error: This.GotMessagePrivateRoom,
        });
    };
    ChatComponent.prototype.GotMessagePrivateRoom = function (res, xHRq, method) {
        if (res && res !== 'null' && typeof res === 'string' && res !== '') {
            res = res.replace('"', '').replace('\\u000a', '').replace(/\\\//g, '/').replace("\\n", '<br/>').replace('"', ''); //normalize res message email address user:
            var normalizedMessage = this.normalizeMessage(res);
            jQuery('div#txtMessages').append(normalizedMessage);
            this.scrollContentDown();
        }
        setTimeout("getMsgs()", 3000);
    };
    ChatComponent.prototype.InviteClient = function () {
        var invitedUser = jQuery("input[type='checkbox'][name='userList']:checked").attr('value');
        if (typeof (invitedUser) != "undefined") {
            var client = { Username: invitedUser, Message: '<b><span style="color:Teal;font-style:italic;">' + invitedUser.substring(0, invitedUser.indexOf('@@')) + ', enter my Conversation at Secret Room via the link in the Public Room Please</span></b><br/>' };
            var jsonData = JSON.stringify(client);
            jQuery.ajax({
                url: "/Chat/InviteClient",
                type: "POST",
                dataType: "json",
                data: jsonData,
                contentType: "application/json"
            });
            return true;
        }
        else {
            return false;
        }
    };
    ChatComponent.prototype.keyDownMessage = function (e) {
        if (e.keyCode == 13) {
            this.wasClicked();
            jQuery('#txtTypeHere').val('');
            jQuery('#txtTypeHere').focus();
        }
    };
    ChatComponent.prototype.scrollContentDown = function () {
        var theDiv = document.getElementById('txtMessages');
        theDiv.scrollTop =
            theDiv.scrollHeight - theDiv.clientHeight;
        var theMsg = document.getElementById('txtTypeHere');
        if (theMsg != null)
            theMsg.focus();
    };
    return ChatComponent;
}());
//# sourceMappingURL=chat.component.js.map