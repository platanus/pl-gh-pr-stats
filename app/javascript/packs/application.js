/* eslint no-console: 0 */
/* global document, window */

import Vue from 'vue/dist/vue.esm';
import VueI18n from 'vue-i18n';
import VTooltip from 'v-tooltip';
import VueHorizontalList from 'vue-horizontal-list';
import Toasted from 'vue-toasted';

import Dropdown from '../components/pl-dropdown.vue';
import TeamsDropdown from '../components/teams-dropdown.vue';
import OrganizationsDropdown from '../components/organizations-dropdown.vue';
import FroggoTeamForm from '../components/froggo-team-form.vue';
import FroggoTeamShow from '../components/froggo-team-show.vue';
import FroggoTeamsList from '../components/froggo-teams-list.vue';
import TimespanDropdown from '../components/timespan-dropdown.vue';
import Repository from '../components/repository.vue';
import EnablePublicButton from '../components/enable-public-button.vue';
import SyncOrganizationButton from '../components/sync-organization-button.vue';
import DashboardSyncingIcon from '../components/dashboard-syncing-icon.vue';
import PublicDashboardCarousel from '../components/public-dashboard/carousel.vue';
import ProfileDropdowns from '../components/profile-dropdowns.vue';
import ProfileRecommendations from '../components/profile/recommendations.vue';
import ProfileStatistics from '../components/profile/statistics.vue';
import PrFeed from '../components/pr-feed.vue';
import PrShow from '../components/pr-show.vue';
import ProfileMetrics from '../components/profile/metrics.vue';

import Locales from '../locales/locales.js';
import store from '../store';

Vue.use(VueI18n);
Vue.use(VTooltip);
Vue.use(VueHorizontalList);

/* eslint-disable max-statements */
document.addEventListener('DOMContentLoaded', () => {
  Vue.use(Toasted, {
    action: {
      icon: 'close',
      onClick: (e, toastObject) => {
        toastObject.goAway(0);
      },
    },
  });
  Vue.component('repository', Repository);
  Vue.component('enable-public-button', EnablePublicButton);
  Vue.component('dropdown', Dropdown);
  Vue.component('teams-dropdown', TeamsDropdown);
  Vue.component('organizations-dropdown', OrganizationsDropdown);
  Vue.component('froggo-team-form', FroggoTeamForm);
  Vue.component('froggo-team-show', FroggoTeamShow);
  Vue.component('froggo-teams-list', FroggoTeamsList);
  Vue.component('timespan-dropdown', TimespanDropdown);
  Vue.component('sync-organization-button', SyncOrganizationButton);
  Vue.component('dashboard-syncing-icon', DashboardSyncingIcon);
  Vue.component('public-dashboard-carousel', PublicDashboardCarousel);
  Vue.component('profile-dropdowns', ProfileDropdowns);
  Vue.component('profile-recommendations', ProfileRecommendations);
  Vue.component('profile-statistics', ProfileStatistics);
  Vue.component('pr-feed', PrFeed);
  Vue.component('pr-show', PrShow);
  Vue.component('profile-metrics', ProfileMetrics);

  if (document.getElementById('app') !== null) {
    new Vue({ // eslint-disable-line no-new
      el: '#app',
      i18n: new VueI18n({
        locale: 'es',
        messages: Locales.messages,
      }),
      store,
      data: {
        activeOrg: null,
      },
      methods: {
        changeOrganization(organization) {
          if (organization === null) {
            return;
          }
          if (this.activeOrg !== organization.login) {
            document.location.href = `/organizations/${organization.login}`;
          }

          return;
        },
      },
      beforeMount() {
        const pathArray = window.location.pathname.split('/');
        const orgNameUrlPos = 1;
        if (pathArray.length > orgNameUrlPos + 1 && pathArray[orgNameUrlPos] === 'organizations') {
          this.activeOrg = pathArray[orgNameUrlPos + 1];
        }
      },
    });
  }
});
