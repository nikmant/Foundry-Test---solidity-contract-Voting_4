// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import { Helper } from "./Helper.sol";
import "../src/Voting_4.sol";

contract Voting_4Test is Test {
    Voting_4 public voi;    

    event EventCandidate  ( uint    indexed Vote
                          , address indexed Candidate
                          );
    event EventVotingDraft( uint indexed Vote );
    event EventVoting     ( uint indexed Vote
                          , uint indexed StartVoting
                          , uint indexed EndVoting
                          , uint LengthVoting
                          );

    function setUp() public {
        voi = new Voting_4();
        voi.CandidateMaxCountEdit(5);
    }
    
    function test_Owner() public {
        //console.log(voi.Owner());
        //console.log(address(this));
        assertEq(voi.Owner(), address(this));
    }
    
    function test_CandidateMaxCountEdit_Simple() public {
        uint t = voi.CandidateMaxCount();
        voi.CandidateMaxCountEdit(t+1);
        assertEq(voi.CandidateMaxCount(), t+1);
    }

    function test_VoitingCountGet() view public {
        voi.VoitingCountGet();
    }
       
    function test_VoitingAdd_Simple() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingAdd(addr, 777);
        voi.VoitingAdd(addr, 777);
        voi.VoitingAdd(addr, 777);
        voi.VoitingAdd(addr, 777);
        voi.VoitingAdd(addr, 777);
    }

    function testFail_VoitingAdd_NotFromOwner() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        vm.prank(address(2));
        voi.VoitingAdd(addr, 777);
    }
    
    function testFail_VoitingAdd_PeriodIsToShort() public {
        voi.VoitingAdd(new address[](0), 0);
    }
           
    function test_VoitingAdd_Event() public {
        vm.expectEmit(true, true, true, true);
        emit EventVotingDraft(0);
        voi.VoitingAdd(new address[](0), 880);
        emit EventVotingDraft(1);
        voi.VoitingAdd(new address[](0), 880);
    }

       
    function test_VoitingStart_Owner() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingStart(0);
    }
    
    function testFail_VoitingStart_NotOwner() public {
        vm.prank(address(2));
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingStart(0);
    }
        
    function testFail_VoitingStart_onlyVotingExists() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingStart(100555);
    }
        
    function test_VoitingStart_Event() public {
        uint L = 2880;
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(new address[](0), L);
        vm.expectEmit(true, true, true, true);
        emit EventVoting(0, block.timestamp, block.timestamp+L, L);
        voi.VoitingStart(0);
    }
        
    function testFail_VoitingStart_onlyDraft() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingStart(0);
        voi.VoitingStart(0);
    }

    function test_VoitingLengthVoting_onlyVotingExists() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingLengthVoting(0,7);
    }

    function testFail_VoitingLengthVoting_onlyVotingExists() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingLengthVoting(345745,7);
    }

    function testFail_VoitingLengthVoting_onlyDraft() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingStart(0);
        voi.VoitingLengthVoting(0,888);
    }

    function testFail_VoitingLengthVoting_onlyOwner() public {
        vm.prank(address(2));
        voi.VoitingAdd(new address[](0), 777);
        voi.VoitingLengthVoting(0,888);
    }

    function test_VoitingLengthVoting_Norma() public {
        address[] memory addr = new address[](2);
        addr[0] = address(2);
        addr[1] = address(3);
        voi.VoitingAdd(addr, 777);
        voi.VoitingLengthVoting(0,888);
        vm.expectEmit(true, true, true, true);
        emit EventVoting(0, block.timestamp, block.timestamp+888, 888);
        voi.VoitingStart(0);
    }


    function testFail_CandidateAdd_ThisCandidateAlreadyExists() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateMaxCountEdit(100);
        voi.CandidateAdd(0, address(3));
        voi.CandidateAdd(0, address(2));
        voi.CandidateAdd(0, address(1));
        voi.CandidateAdd(0, address(1));
    }

    function testFail_CandidateAdd_onlyDraft() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.VoitingStart(0);
        voi.CandidateMaxCountEdit(100);
        voi.CandidateAdd(0, address(5));
    }

    function testFail_CandidateAdd_onlyOwner() public {
        vm.prank(address(2));
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(5));
    }

    function test_CandidateAdd_Norma() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.VoitingAdd(new address[](0), 999);
        voi.CandidateAdd(1, address(5));
        voi.VoitingAdd(new address[](0), 999);
        voi.CandidateAdd(2, address(4));
        voi.CandidateAdd(2, address(5));
    }

    function test_CandidateAdd_ToManyCandidates() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateMaxCountEdit(2);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        vm.expectRevert("To many candidates");
        voi.CandidateAdd(0, address(9));
    }
   

    function test_GetVoteInfo() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        voi.CandidateAdd(0, address(9));
        voi.VoitingStart(0);
        (
            bool    _IsStarted,
            uint256 _CandidateCount,
            uint256 _StartVoting,
            uint256 _CurrentTimeStamp,
            uint256 _EndVoting,
            uint256 _LengthVoting,
            uint256 _Bank,
            uint256 _WinnerBalance,
            address _WinnerAddress
        ) = voi.GetVoteInfo(0);
        assertEq(voi.Owner(), address(this));
        assertEq(_IsStarted, true);
        assertEq(_CandidateCount, 3);
        assertEq(_StartVoting, block.timestamp);
        assertEq(_CurrentTimeStamp, block.timestamp);
        assertEq(_EndVoting, block.timestamp+777);
        assertEq(_LengthVoting, 777);
        assertEq(_Bank, 0);
        assertEq(_WinnerBalance, 0);
        assertEq(_WinnerAddress, address(0));
    }


    function test_CandidateDelete_onlyDraft() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        voi.CandidateAdd(0, address(9));
        voi.VoitingStart(0);
        vm.expectRevert("Already started!");
        voi.CandidateDelete(0, address(8));
    }
    function test_CandidateDelete_CandidateNotExists() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        voi.CandidateAdd(0, address(9));
        voi.CandidateDelete(0, address(8));
        vm.expectRevert("This Candidate NOT Exists");
        voi.CandidateDelete(0, address(8));
    }
    function test_CandidateDelete_OnlyOwner() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        vm.prank(address(7));
        vm.expectRevert("Only Owner!");
        voi.CandidateDelete(0, address(8));
    }
    function test_CandidateDelete_Norma() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        voi.CandidateAdd(0, address(8));
        voi.CandidateAdd(0, address(9));
        voi.CandidateDelete(0, address(7));
        voi.CandidateDelete(0, address(8));
        voi.CandidateAdd(0, address(10));
    }
    function test_CandidateDelete_VoiNotExist() public {
        vm.expectRevert("Voiting NOT exists!");
        voi.CandidateDelete(5, address(55));
    }
    
    function test_Vote_VoiNotExist() public {
        vm.expectRevert("Voiting NOT exists!");
        voi.Vote(5, address(55));
    }
    function test_Vote_VoiNotStart() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(7));
        vm.expectRevert("This voting not started yet!");
        voi.Vote(0, address(7));
    }
    function test_Vote_CandidateNotExist() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(4));
        voi.VoitingStart(0);
        vm.expectRevert("Candidate does not exists!");
        voi.Vote{value: 10000000}(0, address(8));
    }
    function test_Vote_VoiIsFinish() public {
        voi.VoitingAdd(new address[](0), 777);
        voi.CandidateAdd(0, address(17));
        voi.VoitingStart(0);
        vm.warp(2000);
        vm.expectRevert("This voting is Finished!");
        voi.Vote{value: 10000000}(0, address(17));
    }
    function test_Vote_Norma() public {
        voi.VoitingAdd(new address[](0), 777);
        uint _st = block.timestamp;
        voi.CandidateMaxCountEdit(55555);
        voi.CandidateAdd(0, address(11));
        voi.CandidateAdd(0, address(12));
        voi.CandidateAdd(0, address(13));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 40000000}(0, address(11));
        hoax(address(2), 100 ether);
        vm.stopPrank();
        hoax(address(3), 100 ether);
        vm.stopPrank();
        vm.startPrank(address(2));
        voi.Vote{value: 20000000}(0, address(12));
        vm.stopPrank();
        vm.startPrank(address(3));
        voi.Vote{value: 30000000}(0, address(13));
        voi.Vote{value: 30000000}(0, address(13));
        vm.stopPrank();
        vm.startPrank(address(2));
        voi.Vote{value: 20000000}(0, address(12));
        assertEq(address(voi).balance, 40000000+20000000*2+30000000*2);
        assertEq(address(3).balance, (100 ether) - 30000000*2);
        (
            bool    _IsStarted,
            uint256 _CandidateCount,
            uint256 _StartVoting,
            uint256 _CurrentTimeStamp,
            uint256 _EndVoting,
            uint256 _LengthVoting,
            uint256 _Bank,
            uint256 _WinnerBalance,
            address _WinnerAddress
        ) = voi.GetVoteInfo(0);
        assertEq(voi.Owner(), address(this));
        assertEq(_IsStarted, true);
        assertEq(_CandidateCount, 3);
        assertEq(_StartVoting, _st);
        assertEq(_CurrentTimeStamp, block.timestamp);
        assertEq(_EndVoting, _st+777);
        assertEq(_LengthVoting, 777);
        assertEq(_Bank, 40000000+20000000*2+30000000*2);
        assertEq(_WinnerBalance, 30000000*2);
        assertEq(_WinnerAddress, address(13));
    }


    function test_GetMyPrice_VoiIsFinish() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(17));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(17));
        vm.expectRevert("This voting is NOT finished!");
        voi.GetMyPrice(0);
    }
 
    function test_GetMyPrice_YouAreNotTheWinner() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(17));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(17));
        vm.warp(10000);
        vm.expectRevert("You are not the Winner!");
        voi.GetMyPrice(0);
    } 

    function test_GetMyPrice_ThisVotingNotStartedYet() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(17));
        vm.warp(200);
        vm.expectRevert("This voting not started yet!");
        voi.GetMyPrice(0);
    }
  
    function test_GetMyPrice_Norma() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(11));
        voi.CandidateAdd(0, address(12));
        voi.CandidateAdd(0, address(13));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(12));
        voi.Vote{value: 20000000}(0, address(11));
        voi.Vote{value: 20000000}(0, address(13));
        voi.Vote{value: 10000000}(0, address(11));
        vm.warp(10000);
        vm.prank(address(11));
        voi.GetMyPrice(0);
    } 


    function test_GetMyCommission_OnlyOwner() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(11));
        voi.CandidateAdd(0, address(12));
        voi.CandidateAdd(0, address(13));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(12));
        voi.Vote{value: 20000000}(0, address(11));
        voi.Vote{value: 20000000}(0, address(13));
        voi.Vote{value: 10000000}(0, address(11));
        vm.warp(10000);
        vm.prank(address(11));
        vm.expectRevert("Only Owner!");
        voi.GetMyCommission(0);
    } 
    function test_GetMyCommission_VoitingNotExists() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(11));
        voi.CandidateAdd(0, address(12));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(11));
        vm.warp(10000);
        vm.expectRevert("Voiting NOT exists!");
        voi.GetMyCommission(555);
    } 
    function test_GetMyCommission_ThisVotingNotStartedYet() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(11));
        vm.warp(200);
        vm.expectRevert("This voting not started yet!");
        voi.GetMyCommission(0);
    } 
    function test_GetMyCommission_ThisVotingIsNotFinished() public {
        voi.VoitingAdd(new address[](0), 7000);
        voi.CandidateAdd(0, address(11));
        voi.CandidateAdd(0, address(12));
        voi.VoitingStart(0);
        vm.warp(200);
        voi.Vote{value: 10000000}(0, address(11));
        vm.warp(200);
        vm.expectRevert("This voting is NOT finished!");
        voi.GetMyCommission(0);
    } 

}