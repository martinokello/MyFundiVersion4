import { Component, OnInit, Inject, AfterViewInit, OnDestroy, NgZone } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, ObservableInput } from 'rxjs';
import { Router } from '@angular/router';
import { AddressLocationGeoCodeService } from '../../services/AddressLocationGeoCodeService';
import { MyFundiService } from '../../services/myFundiService';
declare let jQuery: any;
declare let sceditor: any;

@Component({
    selector: 'chat',
    templateUrl: './chat.component.html',
    providers: [AddressLocationGeoCodeService, MyFundiService]
})
export class ChatComponent implements OnInit, AfterViewInit, OnDestroy {
    userRoles: string[];
    roomNumber: number;
    thisCurrent: any;
    listTimeout: any;
    messageTimeout: any;
    broadcastMessageTimeout: any;
    checkRegisterTimeout: any;
    inviteResetRoomNumber: boolean;

    constructor(private router: Router, private zone: NgZone, private myFundiService: MyFundiService, private addressLocationGeoCodeService: AddressLocationGeoCodeService) {
       
    }
    normalizeMessage(message) {
        return message.replace(/@[a-zA-Z0-9\.]+:/, ':');
    }

    LoadUserList() {
        let curThis = this;
		jQuery.ajax({
			url: "/Adhoc/GetAllUsers",
			type: "GET",
			dataType: "json",
			cache: false,
			success: function (userList) {

				if(userList)
				{
                    let userListCont = document.getElementById('radioList');

                    if (userList.length > 0) {
                        for (var i = 0; i < userList.length; i++) {
                            //only create checkbox if not exists:                  
                            if (jQuery(userListCont).find('input[name="' + userList[i].username + '"]').length < 1) {
                                let divwrapper = document.createElement('div');
                                divwrapper.setAttribute('style', 'margin-left:0px !important;')
                                divwrapper.setAttribute('class', 'custom-control');
                                let element = document.createElement("input");
                                let id = 'userList' + userList[i].username;
                                element.setAttribute('type', 'checkbox');
                                element.setAttribute('class', 'custom-control-input');
                                element.setAttribute('style', '!important;display:inline-block !important;z-index:2000 !important; visibility:visible !important;');
                                element.setAttribute('name', userList[i].username);
                                element.setAttribute('id', id);
                                divwrapper.appendChild(element);
                                let lbl = document.createElement('label');
                                lbl.setAttribute('class', 'custom-control-label');
                                lbl.setAttribute('style', 'width:90% !important;display:inline-block !important;');
                                lbl.innerHTML = userList[i].username;
                                divwrapper.appendChild(lbl);
                                jQuery(divwrapper).css('color', 'green');
                                let li = document.createElement("li");
                                li.setAttribute('style', 'margin-left:0px !important;');
                                jQuery(li).append(divwrapper);
                                jQuery(userListCont).append(li);
                            }
                        }
                    }
                    else {
                        jQuery(userListCont).children().remove();
                    }

                    let curChecboxes = jQuery(userListCont).find('input[type="checkbox"]');
                    if (curChecboxes.length > 0) {
                        for (let i = 0; i < userList.length; i++) {
                            let found = false;
                            for (let c = 0; c < curChecboxes.length; c++) {
                                if (jQuery(curChecboxes[c]).attr('name') === userList[i].username) {
                                    found = true;
                                }
                                if (!found) {
                                    jQuery(userListCont).children('input[name="' + userList[i].username + '"]').parent('li').remove();
                                }
                            }
                        }
                    }
				}
			},
			error: function () {
				
			}
		});
    }
    BookPrivateRoom($event) {
        let curThis = this;
        //Create Client Object:
        let client = { username: JSON.parse(localStorage.getItem("userDetails")).username, currentMessage:  'Has Booked A Room' };
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

    IsInSecretRoom() {
        let curThis = this;
        let userName = JSON.parse(localStorage.getItem("userDetails")).username;
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
        let userName = JSON.parse(localStorage.getItem("userDetails")).username;
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
        let userName = JSON.parse(localStorage.getItem("userDetails")).username;
        let textarea = jQuery('#txtTypeHere')[0];
        let scEditInstance = sceditor.instance(textarea);
        let message = scEditInstance.getBody().innerHTML;
        let curThis = this;
        scEditInstance.setWysiwygEditorValue('');
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

                    let theMsg = document.getElementById('txtTypeHere');
                    jQuery(theMsg).html('');
                    jQuery(theMsg).focus();
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

                        if (parseInt(localStorage.getItem('roomNumber')) && msg && !msg.match(/@[a-zA-Z0-9\.]+: <\/span><br>$/g) && jQuery('div#messages').html().indexOf(msg) < 0) {

                            jQuery('div#messages').append(msg);

                            let theDiv = document.getElementById('messages');
                            theDiv.scrollTop =
                                theDiv.scrollHeight - theDiv.clientHeight;

                            let theMsg = document.getElementById('txtTypeHere');
                            jQuery(theMsg).focus();
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
                if (msg.match(/\[\[[1-9]+-Invite\]\]$/g) && msg.indexOf(JSON.parse(localStorage.getItem("userDetails")).username)>0) {
                    let msg2 = msg.substring(msg.indexOf("[[")+2);
                    msg2 = msg2.split("-")[0];
                    let tmpRoomNo = curThis.roomNumber;
                    try {
                        curThis.roomNumber = parseInt(msg2);
                        localStorage.setItem("roomNumber", msg2);
                        if (!curThis.inviteResetRoomNumber) {
                            curThis.inviteResetRoomNumber = true;
                            window.location.href = "/";
                        }
                    }
                    catch (e) {
                        curThis.roomNumber = tmpRoomNo;
                        localStorage.setItem('roomNumber', tmpRoomNo.toString());
                    }
                }
                if (msg && !msg.match(/@[a-zA-Z0-9\.]+: <\/span><br><\/div>$/g) && jQuery('div#messages').html().indexOf(msg) < 0) {

                    //let normalizedMessage = curThis.normalizeMessage(msg);
                    jQuery('div#messages').append(msg);

                    let theDiv = document.getElementById('messages');
                    theDiv.scrollTop =
                        theDiv.scrollHeight - theDiv.clientHeight;

                    let theMsg = document.getElementById('txtTypeHere');
                    jQuery(theMsg).focus();
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
            let client = { username: invitedUser, roomNumber: parseInt(localStorage.getItem('roomNumber')), currentMessage: '<em><span style="color:Teal;font-style:italic;font-weight:bold;">' + invitedUser + ', enter my Conversation at Private Room via the link in the Public Room Please</span></em><br>' };
            localStorage.setItem("InvitedUsername", client.username);
            let jsonData = JSON.stringify(client);
            jQuery.ajax({
                url: "/Adhoc/InviteClient",
                type: "POST",
                dataType: "json",
                cache: false,
                data: jsonData,
                contentType: "application/json",
                success: function (data) {
                    alert(data.username + ", was added to room" + client.roomNumber);
                },
                error: function (xHRq, status, error) {
                    alert(localStorage.getItem("InvitedUsername") + ", failed to be added to room" + client.roomNumber);
                }
            });
        }

        $event.preventDefault();
    }
  
	checkRegisterAvailability(){
        let username = JSON.parse(localStorage.getItem("userDetails")).username;
        let newClient = { username: username, currentMessage: '<em><span style="color:Orange;font-style:italic;font-weight:bolder;">' + username + ',Available</ span > </em><br>', roomNumber: 0 };
        let data = JSON.stringify(newClient);
        jQuery.ajax({
            url: "/Adhoc/CheckRegisterUserAvailability",
            type: "POST",
            data: data,
            dataType: "json",
            cache: false,
            contentType: "application/json",
            success: function (result) {
                console.log(username+' availability check: '+result.isRegistered);
            },
            error: function () {
            }
        });
	}
    ngOnInit() {

        jQuery("div#chat-wrapper").on('focus', 'div textarea#txtTypeHere', function () {
            debugger;
            let textarea = this;
            sceditor.create(textarea, {
                format: 'bbcode',
                width: '100%',
                icons: 'monocons',
                style: 'minified/themes/content/default.min.css'
            });

        });
        jQuery("textarea#txtTypeHere").on('keydown', function keyDownMessage(event) {
            debugger;
            if (event.keyCode == 13) {
                this.wasClicked(event);
            }
        });
        this.userRoles = JSON.parse(localStorage.getItem("userRoles"));

        if (localStorage.getItem('roomNumber')) {
            this.roomNumber = parseInt(localStorage.getItem('roomNumber'));
        }

    }
    ngAfterViewInit() {

        let curThis = this;

        let username = JSON.parse(localStorage.getItem("userDetails")).username;
        this.listTimeout = setInterval(this.LoadUserList, 4500);
        this.messageTimeout = setInterval(this.getMsgs, 2500);
        this.broadcastMessageTimeout = setInterval(this.getBroadcastMsgs, 4000);
		this.checkRegisterTimeout = setInterval(this.checkRegisterAvailability,5000);
		
        if (localStorage.getItem('roomNumber')) {
            curThis.roomNumber = parseInt(localStorage.getItem('roomNumber'));
        }
        if (MyFundiService.actUserStatus.isUserLoggedIn) {
            let client = { username: username, roomNumber: curThis.roomNumber, currentMessage: '<em><span style="color:Teal;font-style:italic;font-weight:bold;">' + username.substring(0, username.indexOf('@')) + ', is available now!!</span></em><br>' };

            let jsonData = JSON.stringify(client);
            jQuery.ajax({
                url: "/Adhoc/AddMessageAllRooms",
                type: "POST",
                dataType: "json",
                data: jsonData,
                cache: false,
                contentType: "application/json",
                success: function (client) {
                }
            });
        }

    }
    ngOnDestroy() {
        localStorage.removeItem('roomNumber');
        let username = JSON.parse(localStorage.getItem("userDetails")).username;
        let newClient = { username: username, currentMessage: '<em><span style="color:Orange;font-style:italic;font-weight:bolder;">' + username + ',Available</ span > </em><br>', roomNumber: 0 };
        let data = JSON.stringify(newClient);
        let curThis = this;
        jQuery.ajax({
            url: "/Adhoc/RemoveUserAvailability",
            type: "POST",
            data: data,
            dataType: "json",
            contentType: "application/json",
            cache: false,
            success: function (result) {
                console.log(JSON.parse(localStorage.getItem("userDetails")).username+' is removed: '+result.isRemoved);
            },
            error: function () {

            }
        });

        if (this.messageTimeout) {
            clearInterval(this.messageTimeout);
        }
        if (this.broadcastMessageTimeout) {
            clearInterval(this.broadcastMessageTimeout);
        }
        if (this.listTimeout) {
            clearInterval(this.listTimeout);
        }
        if (this.checkRegisterTimeout) {
            clearInterval(this.checkRegisterTimeout);
        }
    }
}