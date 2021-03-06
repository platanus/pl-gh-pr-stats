<template>
  <div class="froggo-teams-show">
    <div class="froggo-teams-show__name">
      <div class="froggo-teams-show__name-container">
        {{ teamName }}
      </div>
      <div
        class="froggo-teams-show__white-button"
        @click="editFroggoTeamName"
      >
        {{ $t("message.froggoTeams.editName") }}
      </div>
    </div>
    <div
      class="froggo-teams-show__edit-name-section"
      v-if="editName"
    >
      <input
        type="text"
        v-model="newName"
      >
      <div
        class="froggo-teams-show__gray-button"
        @click="submitName()"
      >
        {{ $t("message.froggoTeams.saveName") }}
      </div>
    </div>
    <div class="froggo-teams-show__members">
      <div class="froggo-teams-show__member-title">
        {{ $t("message.froggoTeams.addMember") }}
      </div>
      <div class="froggo-teams-show__dropdown">
        <clickable-dropdown
          :body-title="dropdownTitle"
          :no-items-message="noUsersMessage"
          :items="possibleMembers"
          @item-clicked="onItemClicked"
        />
      </div>
      <div class="froggo-teams-show__member-title">
        {{ $t("message.froggoTeams.members") }}
        ( {{ membersCounter }} )
      </div>
      <div
        class="froggo-teams-show__member-container"
        v-for="(user, index) in currentMembers"
        :key="user.id"
      >
        <a
          class="froggo-teams-show__member-container-info"
          :href="`/users/${user.id}`"
        >
          <img
            class="froggo-teams-show__picture"
            :src="user.avatarUrl"
          >
          <div class="froggo-teams-show__username">
            {{ user.login }}
          </div>
        </a>
        <div
          class="froggo-teams-show__gray-button"
          @click="removeMember(user, index)"
        >
          {{ $t("message.froggoTeams.deleteFromTeam") }}
        </div>
      </div>
    </div>
    <div class="froggo-teams-show__end-section">
      <div
        class="froggo-teams-show__gray-button"
        @click="deleteFroggoTeam"
      >
        {{ $t("message.froggoTeams.deleteTeam") }}
      </div>
      <div
        class="froggo-teams-show__gray-button"
        @click="saveFroggoTeam"
      >
        {{ $t("message.froggoTeams.saveChanges") }}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import {
  UPDATE_FROGGO_TEAM,
  DELETE_FROGGO_TEAM,
} from '../store/action-types';
import {
  TEAM_NAME,
  LOAD_MEMBERS,
  ADD_MEMBER,
  REMOVE_MEMBER,
} from '../store/mutation-types';
import ClickableDropdown from './clickable-dropdown';
import showMessageMixin from '../mixins/showMessageMixin';

export default {
  mixins: [showMessageMixin],
  beforeMount() {
    this.$store.commit(TEAM_NAME, this.froggoTeam.name);
    this.$store.commit(LOAD_MEMBERS, { members: this.froggoTeamMembers,
      possibleMembers: this.organizationMembers });
  },
  data() {
    return {
      dropdownTitle: 'Usuarios',
      noUsersMessage: 'No se encontraron usuarios',
      editName: false,
      newName: '',
      usersToAdd: [],
      usersToRemove: [],
    };
  },
  props: {
    userId: {
      type: Number,
      required: true,
    },
    froggoTeam: {
      type: Object,
      required: true,
    },
    froggoTeamMembers: {
      type: Array,
      required: true,
    },
    organizationMembers: {
      type: Array,
      required: true,
    },
  },
  methods: {
    editFroggoTeamName() {
      this.editName = !this.editName;
    },
    submitName() {
      this.$store.dispatch(UPDATE_FROGGO_TEAM, {
        name: this.newName,
        id: this.froggoTeam.id,
      })
        .then(() => {
          this.$store.commit(TEAM_NAME, this.newName);
        })
        .catch(() => {
          this.showMessage(this.$i18n.t('message.error.existentName'));
        });
    },
    onItemClicked({ item }) {
      this.addMember(item);
    },
    addMember(user) {
      if (this.froggoTeamMembers.some(u => u.id === user.id)) {
        const index = this.usersToRemove.findIndex(u => u.id === user.id);
        this.usersToRemove.splice(index, 1);
      } else {
        this.usersToAdd = [...this.usersToAdd, user];
      }
      this.$store.commit(ADD_MEMBER, user);
    },
    removeMember(user, userIndex) {
      if (this.froggoTeamMembers.some(u => u.id === user.id)) {
        this.usersToRemove = [...this.usersToRemove, user];
      } else {
        const index = this.usersToAdd.findIndex(u => u.id === user.id);
        this.usersToAdd.splice(index, 1);
      }
      this.$store.commit(REMOVE_MEMBER, { index: userIndex, member: user });
    },
    saveFroggoTeam() {
      this.$store.dispatch(UPDATE_FROGGO_TEAM, {
        newMembersIds: this.usersToAdd.map(user => user.id),
        oldMembersIds: this.usersToRemove.map(user => user.id),
        id: this.froggoTeam.id,
      })
        .then(() => {
          this.showMessage(this.$i18n.t('message.froggoTeams.successfullySavedChanges'));
          this.usersToAdd = [];
          this.usersToRemove = [];
          window.location.href = `/froggo_teams/${this.froggoTeam.id}`;
        });
    },
    deleteFroggoTeam() {
      this.$store.dispatch(DELETE_FROGGO_TEAM, {
        id: this.froggoTeam.id,
      })
        .then(response => {
          if (response) {
            window.location.href = `/github_users/${this.userId}/froggo_teams`;
          }
        });
    },
  },
  components: {
    ClickableDropdown,
  },
  computed: {
    membersCounter() {
      return this.currentMembers.length;
    },
    ...mapState({
      teamName: state => state.froggoTeam.teamName,
      currentMembers: state => state.froggoTeam.currentMembers,
      possibleMembers: state => state.froggoTeam.possibleMembers,
    }),
  },
};
</script>
