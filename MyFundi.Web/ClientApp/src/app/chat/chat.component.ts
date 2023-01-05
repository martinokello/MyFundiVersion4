import { Component, OnInit, Inject, AfterViewInit, OnDestroy, NgZone } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, ObservableInput } from 'rxjs';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
import { MyFundiService } from '../../services/myFundiService';
declare let jQuery: any;


@Component({
    selector: 'chat',
    templateUrl: './chat.component.html',
    providers: [AddressLocationGeoCodeService, MyFundiService]
})
export class ChatComponent implements OnInit, AfterViewInit, OnDestroy {
    userDetails: any;
    userRoles: string[];
    roomNumber: number;
    thisCurrent: any;
    listTimeout: any;
    messageTimeout: any;
    broadcastMessageTimeout: any;

    constructor(private router: Router, private zone: NgZone, private myFundiService: MyFundiService, private addressLocationGeoCodeService: AddressLocationGeoCodeService) {

    }
    normalizeMessage(message) {
        return message.replace(/@[a-zA-Z0-9\.]+:/, ':');
    }
    RemoveUserListItems(radioList) {
        let userListCont = document.getElementById(radioList);

        jQuery(userListCont).empty();
    }

    LoadUserList() {
        let curThis = this;
        if (this.roomNumber) {

            jQuery.ajax({
                url: "/Adhoc/GetUserList/" + localStorage.getItem('roomNumber'),
                type: "GET",
                dataType: "json",
                cache: false,
                success: function (userList) {

                    curThis.RemoveUserListItems('radioList');

                    let userListCont = document.getElementById('radioList');

                    if (userList.length > 0) {
                        for (var i = 0; i < userList.length; i++) {
                                //only create checkbox if not exists:
                                let length = jQuery(userListCont).find('input:checkbox[name="' + userList[i].username + '"]').length;
                                if (length === 0) {
                                    let divWithcheckbox = curThis.CreateCheckbox('userList', userList[i].username);
                                    jQuery(divWithcheckbox).css('color', 'green');
                                    let li = document.createElement("li");
                                    jQuery(li).append(divWithcheckbox);
                                    jQuery(userListCont).append(li);
                                }
                            }
                    }

                },
                error: function () {
                    
                }
            });
        }
    }

    AddJoiningUsersToList(client: any) {
        let userListCont = document.getElementById('radioList');

        let checkbox = null;


        if (client && !(jQuery('ul#radioList').find('radioList > li checkbox[id="userList' + client.username + '"]').length > 0)) {
            let divwrapper = this.CreateCheckbox('userList', client.username);
            jQuery(userListCont).append(divwrapper);
        }
    }
    BookPrivateRoom($event) {
        let curThis = this;
        let userName = curThis.userDetails.username;
        //Create Client Object:
        let client = { username: userName, currentMessage:  'Has Booked A Room' };
        let jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Adhoc/BookPrivateRoom",
            type: "POST",
            data: jsonData,
            cache: false,
            dataType: "json",
            contentType: "application/json",
            success: function (data) {
                if (data) {
                    curThis.roomNumber = data.roomNumber;
                    localStorage.setItem('roomNumber', data.roomNumber);
                    alert('You booked Private Room: #' + curThis.roomNumber);
                }
            }
        });
        $event.preventDefault();
    }
    CreateCheckbox(name, value) {
        let divwrapper = document.createElement('div');
        divwrapper.setAttribute('style', 'margin-left:1em !important;')
        divwrapper.setAttribute('class', 'custom-control');
        let element = document.createElement("input");
        let id = name + value;
        element.setAttribute('type', 'checkbox');
        element.setAttribute('class', 'custom-control-input');
		element.setAttribute('style','left:4% !important;display:inline-block !important;z-index:2000 !important; visibility:visible !important;');
        element.setAttribute('name', value);
        element.setAttribute('id', id);
        divwrapper.appendChild(element);
        let lbl = document.createElement('label');
        lbl.setAttribute('class', 'custom-control-label');
        lbl.setAttribute('style', 'width:80% !important;display:inline-block !important;');
        lbl.innerHTML = value;
        divwrapper.appendChild(lbl);
        return divwrapper;
    }
    IsInSecretRoom() {
        let curThis = this;
        let userName = this.userDetails.username;
        //Create Client Object:
        let client = { username: userName, Message: '', roomNumber: parseInt(localStorage.getItem('roomNumber')) };
        let jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Adhoc/IsInPrivateRoom/" + localStorage.getItem('roomNumber'),
            type: "POST",
            data: jsonData,
            dataType: "json",
            contentType: "application/json",
            cache: false,
            success: function (data) {
                if (data !== true) {

                    curThis.router.navigateByUrl('home');
                }
            }
        });
    }

    ClearRoom($event) {
        let curThis = this;
        jQuery.ajax({
            url: "/Adhoc/ClearPrivateRoom/" + localStorage.getItem('roomNumber'),
            cache: false,
            type: "GET"
        });

        $event.preventDefault();
    }

    ExitRoom($event) {
        let userName = this.userDetails.username;
        let curThis = this;
        //Create Client Object:
        let client = { username: userName, currentMessage: 'Client has exited the Secret Room.\n', roomNumber: parseInt(localStorage.getItem('roomNumber')) };

        let jsonData = JSON.stringify(client);
        jQuery.ajax({
            url: "/Adhoc/ExitPrivateRoom",
            type: "POST",
            dataType: "json",
            cache: false,
            data: jsonData,
            contentType: "application/json"
        });
        $event.preventDefault();
        this.router.navigateByUrl('home');
    }
    wasClicked($event) {
        let userName = this.userDetails.username;

        let message = jQuery('#txtTypeHere').val();
        let curThis = this;
        jQuery('#txtTypeHere').val('');
        //Create Client Object:
        let client = { username: userName, currentMessage: message, roomNumber: this.roomNumber };
        let jsonData = JSON.stringify(client);
        if (this.roomNumber) {
            jQuery.ajax({
                url: "/Adhoc/AddMessagePrivateRoom",
                type: "POST",
                cache: false,
                dataType: "json",
                data: jsonData,
                contentType: "application/json",
                success: function (messageAdded) {
                    console.log(messageAdded.toString());
                }
            });
        }

        $event.preventDefault();
    }

    getMsgs() {
        let curThis = this;
        if (localStorage.getItem('roomNumber')) {

            jQuery.ajax({
                url: "/Adhoc/GetMessage/" + localStorage.getItem('roomNumber'),
                type: "GET",
                cache: false,
                dataType: "json",
                contentType: "application/json",
                success: function (res, xHRq, method) {

                    if (res) {
                        let msg = res.clientMessage;
                        
                        if (msg && !msg.match(/@[a-zA-Z0-9\.]+: <\/span><br>$/g)) {
                            //normalize res message email address user:
                            //let normalizedMessage = curThis.normalizeMessage();
                            if (jQuery('div#txtMessages').html().indexOf(msg) < 0) {
                                jQuery('div#txtMessages').append(msg);
                            }
                            //curThis.scrollContentDown();

                        }
                    }
                },
                error: function (xHRq, status, error) {
                    //console.log(xHRq.responseText);

                },
            });
        }
    }
    getBroadcastMsgs() {
        let curThis = this;

        jQuery.ajax({
            url: "/Adhoc/GetBroadcastMessages",
            type: "GET",
            cache:false,
            dataType: "json",
            contentType: "application/json",
            success: function (res, xHRq, method) {
                let msg = res.message;

                if (msg && !msg.match(/@[a-zA-Z0-9\.]+: <\/span><br><\/div>$/g)) {

                    //let normalizedMessage = curThis.normalizeMessage(msg);
                    if (jQuery('div#txtMessages').html().indexOf(msg) < 0) {
                        jQuery('div#txtMessages').append(msg);
                    }
                    //curThis.scrollContentDown();
                }
            },
            error: function (xHRq,status, error) {
                //console.log(xHRq.responseText);
            },
        });
    }


    InviteClient($event) {

        let curThis = this;
        let invitedUser = jQuery("input[type='checkbox']:checked").attr('name');
        if (typeof (invitedUser) != "undefined") {
            let client = { username: invitedUser, roomNumber: parseInt(localStorage.getItem('roomNumber')), currentMessage: '<em><span style="color:Teal;font-style:italic;font-weight:bold;">' + invitedUser.substring(0, invitedUser.indexOf('@')) + ', enter my Conversation at Secret Room via the link in the Public Room Please</span></em><br>' };

            let jsonData = JSON.stringify(client);
            jQuery.ajax({
                url: "/Adhoc/InviteClient/" + curThis.roomNumber,
                type: "POST",
                dataType: "json",
                cache: false,
                data: jsonData,
                contentType: "application/json"
            });
        }

        $event.preventDefault();
    }
    keyDownMessage($event) {
        if ($event.keyCode == 13) {
            this.wasClicked($event);
            jQuery('#txtTypeHere').val('');
            jQuery('#txtTypeHere').focus();
        }
    }
    scrollContentDown() {
        let theDiv = document.getElementById('txtMessages');
        theDiv.scrollTop =
            theDiv.scrollHeight - theDiv.clientHeight;

        let theMsg = document.getElementById('txtTypeHere');
        if (theMsg != null)
            theMsg.focus();
    }

    ngOnInit() {

        let curThis = this;
        if (localStorage.getItem('roomNumber')) {
            curThis.roomNumber = parseInt(localStorage.getItem('roomNumber'));
        }
        jQuery('textarea#txtTypeHere').focus();
        jQuery("div#chat-wrapper").keydown(curThis.keyDownMessage);

        this.userDetails = JSON.parse(localStorage.getItem("userDetails"));

        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

    }
    ngAfterViewInit() {
        let curThis = this;
        if (localStorage.getItem('roomNumber')) {
            curThis.roomNumber = parseInt(localStorage.getItem('roomNumber'));
        }
        if (MyFundiService.actUserStatus.isUserLoggedIn) {
            let client = { username: this.userDetails.username, roomNumber: curThis.roomNumber, currentMessage: '<em><span style="color:Teal;font-style:italic;font-weight:bold;">' + this.userDetails.username.substring(0, this.userDetails.username.indexOf('@')) + ', is available now!!</span></em><br>' };

            let jsonData = JSON.stringify(client);
            jQuery.ajax({
                url: "/Adhoc/AddMessageAllRooms",
                type: "POST",
                dataType: "json",
                data: jsonData,
                cache: false,
                contentType: "application/json",
                success: function (client) {
                    curThis.AddJoiningUsersToList(client);
                }
            });
        }
        this.messageTimeout = setInterval(this.getMsgs, 2500);
        this.broadcastMessageTimeout = setInterval(this.getBroadcastMsgs, 4000);
        this.listTimeout = setInterval(this.LoadUserList, 6000);

    }
    ngOnDestroy() {
        if (this.messageTimeout) {
            clearInterval(this.messageTimeout);
        }
        if (this.broadcastMessageTimeout) {
            clearInterval(this.broadcastMessageTimeout);
        }
        if (this.listTimeout) {
            clearInterval(this.listTimeout);
        }
    }
}